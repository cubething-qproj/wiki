// Dev server for the wiki. Modelled on the blog's vite.config.mts, without
// its incremental builds: the whole bundle compiles in tens of milliseconds.
//
// - Rebuilds on any source change: scripts/manifest.py (page list) → typst
//   bundle → pagefind (search index). Pages added, removed or renamed are
//   picked up, because the manifest is regenerated every time.
// - Serves the built pages from out/ at the site root (`/debate.html`), and
//   the editor (editor/) as an ordinary Vite page at `/editor/?page=<name>`.
// - After each build, sends a `wiki:built` event. Pages reload themselves on
//   it; the editor shows the result instead of reloading.
// - `/api/src` reads and writes page sources for the editor.
// - `/lsp` is a WebSocket bridged to `tinymist lsp`, for the editor's
//   diagnostics, completions and hover.

import { spawn } from "node:child_process";
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import type { IncomingMessage, ServerResponse } from "node:http";
import { dirname, extname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, type Plugin, type ViteDevServer } from "vite";
import { type WebSocket, WebSocketServer } from "ws";

const wikiRoot = dirname(fileURLToPath(import.meta.url));

/** Run a command in the wiki root, rejecting with its output on failure. */
function run(command: string, args: string[], env: NodeJS.ProcessEnv = {}): Promise<void> {
	return new Promise((resolve, reject) => {
		const child = spawn(command, args, { cwd: wikiRoot, env: { ...process.env, ...env } });
		let output = "";
		child.stdout.on("data", (d) => (output += d));
		child.stderr.on("data", (d) => (output += d));
		child.on("error", reject);
		child.on("close", (code) =>
			code === 0 ? resolve() : reject(new Error(`${command} failed:\n${output.trim()}`)),
		);
	});
}

const out = join(wikiRoot, "out");
const next = join(wikiRoot, ".out-next");

/**
 * The whole build: the same steps as `just build`, except that Typst
 * compiles into `.out-next/` first. Only a successful build replaces `out/`,
 * and pages that no longer exist are deleted there, since Typst never removes
 * files.
 */
async function build(): Promise<void> {
	await run("python3", ["scripts/manifest.py"]);
	rmSync(next, { recursive: true, force: true });
	await run("typst", ["compile", "main.typ", next, "--format=bundle"], {
		TYPST_FEATURES: "bundle,html",
	});
	mkdirSync(out, { recursive: true });
	const fresh = new Set(readdirSync(next));
	for (const file of readdirSync(out)) {
		if (file.endsWith(".html") && !fresh.has(file)) rmSync(join(out, file));
	}
	cpSync(next, out, { recursive: true });
	rmSync(next, { recursive: true, force: true });
	await run("pagefind", ["--site", "out", "--silent"]);
}

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
function pageFile(name: string | null): string | undefined {
	const manifest = JSON.parse(readFileSync(join(wikiRoot, "manifest.json"), "utf8"));
	const page = manifest.pages.find((p: { name: string }) => p.name === name);
	return page && join(wikiRoot, page.path);
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
 * `GET /api/src?page=<name>` returns `{ root, path, text, mtime }`.
 * `POST /api/src?page=<name>` with `{ text, mtime }` overwrites the file,
 * unless it changed on disk since `mtime` (409, so the editor never silently
 * overwrites someone else's edit). Only pages in the manifest can be touched.
 */
async function sourceApi(req: IncomingMessage, res: ServerResponse) {
	const file = pageFile(new URL(req.url ?? "", "http://localhost").searchParams.get("page"));
	if (!file) return sendJson(res, { error: "unknown page" }, 404);
	const mtime = statSync(file).mtimeMs;
	if (req.method === "GET") return sendJson(res, { root: wikiRoot, path: file, text: readFileSync(file, "utf8"), mtime });
	if (req.method !== "POST") return sendJson(res, { error: "method not allowed" }, 405);
	const body = JSON.parse(await readBody(req));
	if (body.mtime !== mtime) return sendJson(res, { error: "changed on disk", mtime }, 409);
	writeFileSync(file, body.text);
	sendJson(res, { mtime: statSync(file).mtimeMs });
}

/**
 * Bridge one WebSocket to a fresh `tinymist lsp`: each WebSocket message is
 * one JSON-RPC message, framed with `Content-Length` headers on stdio.
 */
function bridgeLsp(ws: WebSocket) {
	const proc = spawn("tinymist", ["lsp"], { cwd: wikiRoot, stdio: ["pipe", "pipe", "ignore"] });
	let buffer = Buffer.alloc(0);
	proc.stdout.on("data", (data: Buffer) => {
		buffer = Buffer.concat([buffer, data]);
		for (;;) {
			const end = buffer.indexOf("\r\n\r\n");
			if (end < 0) return;
			const length = Number(/content-length: *(\d+)/i.exec(buffer.subarray(0, end).toString())?.[1]);
			if (buffer.length < end + 4 + length) return;
			ws.send(buffer.subarray(end + 4, end + 4 + length).toString());
			buffer = buffer.subarray(end + 4 + length);
		}
	});
	ws.on("message", (message) => {
		const text = message.toString();
		proc.stdin.write(`Content-Length: ${Buffer.byteLength(text)}\r\n\r\n${text}`);
	});
	ws.on("close", () => proc.kill());
	proc.on("exit", () => ws.close());
}

/** Page sources and the manifest script; not anything under out/ or node_modules/. */
function isSource(file: string): boolean {
	const rel = relative(wikiRoot, file).split(sep).join("/");
	if (rel.startsWith("out/") || rel.startsWith(".out-next/") || rel.startsWith("node_modules/")) return false;
	return rel.endsWith(".typ") || rel === "scripts/manifest.py";
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
				server.config.logger.info(`wiki built in ${Math.round(performance.now() - started)} ms`, {
					timestamp: true,
				});
				lastError = undefined;
				server.ws.send({ type: "custom", event: "wiki:built", data: {} });
			} catch (error) {
				const message = String(error instanceof Error ? error.message : error);
				lastError = message;
				server.config.logger.error(message, { timestamp: true });
				server.ws.send({ type: "custom", event: "wiki:built", data: { error: message } });
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
			server.middlewares.use("/pagefind", (req, res, next) => {
				const file = join(out, "pagefind", decodeURIComponent((req.url ?? "").split("?")[0]));
				if (!file.startsWith(join(out, "pagefind") + sep)) return next();
				try {
					const body = readFileSync(file);
					res.setHeader("Content-Type", contentTypes[extname(file)] ?? "application/octet-stream");
					res.end(body);
				} catch {
					next();
				}
			});
			// Built pages live in out/ but are served from the root, so links
			// between them (flat, relative) keep working.
			server.middlewares.use((req, _res, next) => {
				const [path, query] = (req.url ?? "/").split("?");
				const file = path === "/" ? "index.html" : decodeURIComponent(path.slice(1));
				if (!file.includes("/") && existsSync(join(out, file))) {
					req.url = `/out/${file}${query ? `?${query}` : ""}`;
				}
				next();
			});
			server.middlewares.use("/api/src", (req, res) => {
				sourceApi(req, res).catch((error) => sendJson(res, { error: String(error) }, 500));
			});
			server.middlewares.use("/api/build", (_req, res) => sendJson(res, { error: lastError }));
			const lsp = new WebSocketServer({ noServer: true });
			server.httpServer?.on("upgrade", (req, socket, head) => {
				if (req.url === "/lsp") lsp.handleUpgrade(req, socket, head, bridgeLsp);
			});
			server.watcher.add(wikiRoot);
			for (const event of ["add", "change", "unlink"] as const) server.watcher.on(event, changed);
			// Don't block startup on the first build; a broken page leaves the server up.
			rebuild();
		},
		transformIndexHtml(_html, ctx) {
			if (!ctx.path.startsWith("/out/")) return;
			return [{ tag: "script", attrs: { type: "module" }, children: reloadClient, injectTo: "body" }];
		},
	};
}

export default defineConfig({
	root: wikiRoot,
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
			ignored: ["**/out/**", "**/.out-next/**", "**/node_modules/**", "**/manifest.json"],
		},
	},
});
