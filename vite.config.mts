// Dev server for the Quell wiki and separate document library. Modelled on the blog's vite.config.mts, without
// its incremental builds: scripts/build.mts builds both reading collections.
//
// - Rebuilds on any source change: scripts/manifest.py (page list) → typst
//   bundle → pagefind (search index). Pages added, removed or renamed are
//   picked up, because the manifest is regenerated every time.
// - Serves /wiki/ and /documents/ with independent search indexes, and
//   the editor (web/editor/) as an ordinary Vite page at `/editor/?page=<name>`.
// - After each build, sends a `wiki:built` event. Pages reload themselves on
//   it; the editor shows the result instead of reloading.
// - `/api/src` reads and writes page sources for the editor.
// - `/lsp` is a WebSocket bridged to `tinymist lsp`, for the editor's
//   diagnostics, completions and hover.

import { spawn } from "node:child_process";
import { existsSync, readFileSync, statSync, writeFileSync } from "node:fs";
import type { IncomingMessage, ServerResponse } from "node:http";
import { dirname, extname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, type Plugin, type ViteDevServer } from "vite";
import { type WebSocket, WebSocketServer } from "ws";
import { build } from "./scripts/build.mts";

const wikiRoot = dirname(fileURLToPath(import.meta.url));

const out = join(wikiRoot, "out");

const contentTypes: Record<string, string> = {
  ".js": "text/javascript",
  ".css": "text/css",
  ".json": "application/json",
};

/**
 * Pages reload themselves after a successful build. Injected into built pages
 * only. Vite leaves injected inline scripts untransformed, so this imports the
 * HMR client itself instead of using `import.meta.hot`.
 */
const reloadClient = `import { createHotContext } from "/@vite/client";
createHotContext("/wiki-page").on("wiki:built", (result) => { if (!result.error) location.reload(); });`;

/** The page's source file, by page name, from the manifest. */
function pageFile(
  name: string | null,
): { path: string; url: string } | undefined {
  const manifest = JSON.parse(
    readFileSync(join(wikiRoot, "manifest.json"), "utf8"),
  );
  const page = manifest.pages.find((p: { name: string }) => p.name === name);
  return page && { path: join(wikiRoot, page.path), url: page.url };
}

function sendJson(res: ServerResponse, body: unknown, status = 200) {
  res.statusCode = status;
  res.setHeader("Content-Type", "application/json");
  res.end(JSON.stringify(body));
}

function readBody(req: IncomingMessage): Promise<string> {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (d) => (body += d));
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

/**
 * `GET /api/src?page=<name>` returns `{ root, path, url, text, mtime }`.
 * `POST /api/src?page=<name>` with `{ text, mtime }` overwrites the file,
 * unless it changed on disk since `mtime` (409, so the editor never silently
 * overwrites someone else's edit). Only pages in the manifest can be touched.
 */
async function sourceApi(req: IncomingMessage, res: ServerResponse) {
  const page = pageFile(
    new URL(req.url ?? "", "http://localhost").searchParams.get("page"),
  );
  if (!page) return sendJson(res, { error: "unknown page" }, 404);
  const file = page.path;
  const mtime = statSync(file).mtimeMs;
  if (req.method === "GET")
    return sendJson(res, {
      root: wikiRoot,
      path: file,
      url: page.url,
      text: readFileSync(file, "utf8"),
      mtime,
    });
  if (req.method !== "POST")
    return sendJson(res, { error: "method not allowed" }, 405);
  const body = JSON.parse(await readBody(req));
  if (body.mtime !== mtime)
    return sendJson(res, { error: "changed on disk", mtime }, 409);
  writeFileSync(file, body.text);
  sendJson(res, { mtime: statSync(file).mtimeMs });
}

/**
 * Bridge one WebSocket to a fresh `tinymist lsp`: each WebSocket message is
 * one JSON-RPC message, framed with `Content-Length` headers on stdio.
 */
function bridgeLsp(ws: WebSocket) {
  const proc = spawn("tinymist", ["lsp"], {
    cwd: wikiRoot,
    stdio: ["pipe", "pipe", "ignore"],
  });
  let buffer = Buffer.alloc(0);
  proc.stdout.on("data", (data: Buffer) => {
    buffer = Buffer.concat([buffer, data]);
    for (;;) {
      const end = buffer.indexOf("\r\n\r\n");
      if (end < 0) return;
      const length = Number(
        /content-length: *(\d+)/i.exec(buffer.subarray(0, end).toString())?.[1],
      );
      if (buffer.length < end + 4 + length) return;
      ws.send(buffer.subarray(end + 4, end + 4 + length).toString());
      buffer = buffer.subarray(end + 4 + length);
    }
  });
  ws.on("message", (message) => {
    const text = message.toString();
    proc.stdin.write(
      `Content-Length: ${Buffer.byteLength(text)}\r\n\r\n${text}`,
    );
  });
  ws.on("close", () => proc.kill());
  proc.on("exit", () => ws.close());
}

/** Page sources and the manifest script; not anything under out/ or node_modules/. */
function isSource(file: string): boolean {
  const rel = relative(wikiRoot, file).split(sep).join("/");
  if (
    rel.startsWith("out/") ||
    rel.startsWith(".out-next/") ||
    rel.startsWith("node_modules/")
  )
    return false;
  return (
    (rel.startsWith("src/") && rel.endsWith(".typ")) ||
    rel === "scripts/manifest.py" ||
    rel.startsWith("static/") ||
    rel.startsWith("web/styles/") ||
    rel.startsWith("web/scripts/")
  );
}

/**
 * Rebuild on source changes, debounced and never two at once. A failed build
 * keeps the last good output and is logged; the next save tries again.
 */
function wikiPlugin(): Plugin {
  let server: ViteDevServer;
  let timer: ReturnType<typeof setTimeout> | undefined;
  let building = false;
  let again = false;
  /** The last build's error, if it failed; editors opened later show it. */
  let lastError: string | undefined;

  const rebuild = async () => {
    if (building) {
      again = true;
      return;
    }
    building = true;
    do {
      again = false;
      const started = performance.now();
      try {
        await build();
        server.config.logger.info(
          `wiki built in ${Math.round(performance.now() - started)} ms`,
          {
            timestamp: true,
          },
        );
        lastError = undefined;
        server.ws.send({ type: "custom", event: "wiki:built", data: {} });
      } catch (error) {
        const message = String(error instanceof Error ? error.message : error);
        lastError = message;
        server.config.logger.error(message, { timestamp: true });
        server.ws.send({
          type: "custom",
          event: "wiki:built",
          data: { error: message },
        });
      }
    } while (again);
    building = false;
  };

  const changed = (file: string) => {
    if (!isSource(file)) return;
    clearTimeout(timer);
    timer = setTimeout(rebuild, 40);
  };

  return {
    name: "wiki",
    apply: "serve",
    configureServer(viteServer) {
      server = viteServer;
      // Pagefind's files are prebuilt bundles: serve them as they are,
      // before Vite's own middleware tries to transform them as modules.
      for (const collection of ["wiki", "documents"]) {
        server.middlewares.use(`/${collection}/pagefind`, (req, res, next) => {
          const root = join(out, collection, "pagefind");
          const file = join(
            root,
            decodeURIComponent((req.url ?? "").split("?")[0]),
          );
          if (!file.startsWith(root + sep)) return next();
          try {
            res.setHeader(
              "Content-Type",
              contentTypes[extname(file)] ?? "application/octet-stream",
            );
            res.end(readFileSync(file));
          } catch {
            next();
          }
        });
      }
      // Serve both reading collections, plus redirects for legacy record URLs.
      server.middlewares.use((req, _res, next) => {
        const [path, query] = (req.url ?? "/").split("?");
        if (path === "/editor/") {
          req.url = `/web/editor/index.html${query ? `?${query}` : ""}`;
          return next();
        }
        const decoded = decodeURIComponent(path);
        const file =
          decoded === "/"
            ? "wiki/index.html"
            : decoded.endsWith("/")
              ? decoded.slice(1) + "index.html"
              : decoded.slice(1);
        if (
          /^(?:(?:wiki|documents)\/)?[^/]+\.html$/.test(file) &&
          existsSync(join(out, file))
        ) {
          req.url = `/out/${file}${query ? `?${query}` : ""}`;
        }
        next();
      });
      server.middlewares.use("/api/src", (req, res) => {
        sourceApi(req, res).catch((error) =>
          sendJson(res, { error: String(error) }, 500),
        );
      });
      server.middlewares.use("/api/build", (_req, res) =>
        sendJson(res, { error: lastError }),
      );
      const lsp = new WebSocketServer({ noServer: true });
      server.httpServer?.on("upgrade", (req, socket, head) => {
        if (req.url === "/lsp") lsp.handleUpgrade(req, socket, head, bridgeLsp);
      });
      server.watcher.add(wikiRoot);
      for (const event of ["add", "change", "unlink"] as const)
        server.watcher.on(event, changed);
      // Don't block startup on the first build; a broken page leaves the server up.
      rebuild();
    },
    transformIndexHtml(_html, ctx) {
      if (!ctx.path.startsWith("/out/")) return;
      return [
        {
          tag: "script",
          attrs: { type: "module" },
          children: reloadClient,
          injectTo: "body",
        },
      ];
    },
  };
}

export default defineConfig({
  root: wikiRoot,
  publicDir: join(wikiRoot, "static"),
  appType: "mpa",
  clearScreen: false,
  plugins: [wikiPlugin()],
  server: {
    host: "localhost",
    port: Number(process.env.WIKI_PORT ?? 3040),
    strictPort: true,
    open: process.env.WIKI_OPEN !== "false",
    watch: {
      // Builds write here; the plugin sends one event per finished build.
      ignored: [
        "**/out/**",
        "**/.out-next/**",
        "**/node_modules/**",
        "**/manifest.json",
      ],
    },
  },
});
