// Dev server for the wiki: serves out/, rebuilds on any source change, and
// reloads the browser. Modelled on the blog's vite.config.mts, without its
// incremental builds: the whole bundle compiles in tens of milliseconds.
//
// A build is: scripts/manifest.py (page list) → typst bundle → pagefind
// (search index). Pages added, removed or renamed are picked up, because the
// manifest is regenerated every time.

import { spawn } from "node:child_process";
import { cpSync, mkdirSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { dirname, extname, join, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, type Plugin, type ViteDevServer } from "vite";

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
				server.ws.send({ type: "full-reload", path: "*" });
			} catch (error) {
				server.config.logger.error(String(error instanceof Error ? error.message : error), {
					timestamp: true,
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
			server.watcher.add(wikiRoot);
			for (const event of ["add", "change", "unlink"] as const) server.watcher.on(event, changed);
			// Don't block startup on the first build; a broken page leaves the server up.
			rebuild();
		},
	};
}

export default defineConfig({
	root: "./out",
	appType: "mpa",
	clearScreen: false,
	plugins: [wikiPlugin()],
	server: {
		host: "localhost",
		port: Number(process.env.WIKI_PORT ?? 3040),
		strictPort: true,
		open: process.env.WIKI_OPEN !== "false",
		watch: {
			// Builds write here; the plugin sends one reload per finished build.
			ignored: ["**/out/**", "**/.out-next/**", "**/node_modules/**", "**/manifest.json"],
		},
	},
});
