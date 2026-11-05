// Shared CLI/dev-server build: Typst → local assets → two search indexes.
import { spawn } from "node:child_process";
import { cpSync, renameSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));

/** Run a build tool in the documentation repository, retaining failure output. */
function run(
  command: string,
  args: string[],
  env: NodeJS.ProcessEnv = {},
): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: root,
      env: { ...process.env, ...env },
    });
    let output = "";
    child.stdout.on("data", (data) => (output += data));
    child.stderr.on("data", (data) => (output += data));
    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) {
        if (output.trim()) console.log(output.trim());
        resolve();
      } else reject(new Error(`${command} failed:\n${output.trim()}`));
    });
  });
}

/** Replace the last good site only after content, assets and both indexes build. */
export async function build(): Promise<void> {
  const next = join(root, ".out-next");
  await run("python3", ["scripts/manifest.py"]);
  rmSync(next, { recursive: true, force: true });
  await run(
    "typst",
    [
      "compile", "--root", ".", "src/main.typ", next, "--format=bundle",
      ...(process.env.WIKI_HOSTED === "true" ? ["--input", "hosted=true"] : []),
    ],
    {
      TYPST_FEATURES: "bundle,html",
    },
  );
  cpSync(join(root, "static"), next, { recursive: true });
  for (const directory of ["styles", "scripts"]) {
    cpSync(join(root, "web", directory), join(next, "web", directory), {
      recursive: true,
    });
  }
  for (const collection of ["wiki", "documents"]) {
    await run("pagefind", [
      "--site",
      join(next, collection),
      "--glob",
      "*.html",
      "--silent",
    ]);
  }
  rmSync(join(root, "out"), { recursive: true, force: true });
  renameSync(next, join(root, "out"));
}

if (import.meta.main) await build();
