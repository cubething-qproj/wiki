// Optional local-browser regression check: `just smoke` (requires Chromium).
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { existsSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { createServer } from "node:net";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { WebSocket } from "ws";

const root = fileURLToPath(new URL("../", import.meta.url));
const temporary = mkdtempSync(join(root, "../../tmp/wiki-browser-"));
const fixture = join(root, "src/wiki/pcg/zz-browser-test.typ");
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const freePort = () =>
  new Promise((resolve) => {
    const server = createServer();
    server.listen(0, "127.0.0.1", () => {
      const port = server.address().port;
      server.close(() => resolve(port));
    });
  });
async function until(check, name) {
  const deadline = Date.now() + 20000;
  let error;
  while (Date.now() < deadline) {
    try {
      const value = await check();
      if (value) return value;
    } catch (cause) {
      error = cause;
    }
    await delay(100);
  }
  throw new Error(`Timed out: ${name}${error ? `\n${error}` : ""}`);
}

let vite,
  chrome,
  socket,
  logs = "";
try {
  // Reuse an explicitly supplied server; never start two builders for one tree.
  const port = process.env.WIKI_TEST_PORT ?? (await freePort());
  const base = `http://localhost:${port}`;
  if (!process.env.WIKI_TEST_PORT) {
    vite = spawn("node", [join(root, "node_modules/vite/bin/vite.js")], {
      cwd: root,
      env: { ...process.env, WIKI_OPEN: "false", WIKI_PORT: String(port) },
      timeout: 90000,
    });
    for (const stream of [vite.stdout, vite.stderr])
      stream.on("data", (data) => {
        logs += data;
      });
    await until(() => logs.includes("wiki built in"), "first dev build");
  }
  const debug = await freePort();
  chrome = spawn(
    "chromium",
    [
      "--headless",
      "--disable-gpu",
      "--no-first-run",
      `--remote-debugging-port=${debug}`,
      `--user-data-dir=${temporary}`,
      "about:blank",
    ],
    { stdio: "ignore", timeout: 60000 },
  );
  const target = await until(
    async () =>
      (
        await fetch(`http://127.0.0.1:${debug}/json/list`).then((r) => r.json())
      ).find(
        (target) => target.type === "page" && target.url === "about:blank",
      )[0],
    "Chromium",
  );
  socket = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    socket.once("open", resolve);
    socket.once("error", reject);
  });
  let serial = 0;
  const pending = new Map();
  const network = [];
  socket.on("message", (data) => {
    const message = JSON.parse(data);
    if (message.method === "Network.responseReceived") {
      const { url, status, mimeType } = message.params.response;
      network.push({ url, status, mimeType });
    }
    if (message.method === "Network.loadingFailed")
      network.push(message.params);
    const item = pending.get(message.id);
    if (item) {
      pending.delete(message.id);
      message.error
        ? item.reject(new Error(JSON.stringify(message.error)))
        : item.resolve(message.result);
    }
  });
  const cdp = (method, params = {}) =>
    new Promise((resolve, reject) => {
      const id = ++serial;
      pending.set(id, { resolve, reject });
      socket.send(JSON.stringify({ id, method, params }));
    });
  const evaluate = async (expression) => {
    const result = await cdp("Runtime.evaluate", {
      expression,
      awaitPromise: true,
      returnByValue: true,
    });
    if (result.exceptionDetails)
      throw new Error(JSON.stringify(result.exceptionDetails));
    return result.result.value;
  };
  await cdp("Page.enable");
  await cdp("Network.enable");
  await cdp("Network.setBlockedURLs", { urls: ["*cdn.jsdelivr.net*"] });
  async function visit(path, selector = "main") {
    const response = await fetch(base + path);
    assert.ok(response.ok, `${path}: HTTP ${response.status}`);
    assert.ok(
      response.headers.get("content-type")?.includes("text/html"),
      `${path}: ${JSON.stringify([...response.headers])}`,
    );
    const navigation = await cdp("Page.navigate", { url: base + path });
    assert.ok(
      !navigation.errorText,
      `${path}: ${navigation.errorText}\n${JSON.stringify(network.slice(-5))}`,
    );
    try {
      await until(
        () =>
          evaluate(
            `location.href === ${JSON.stringify(base + path)} && !!document.querySelector(${JSON.stringify(selector)})`,
          ),
        path,
      );
    } catch (error) {
      throw new Error(
        `${error}\n${await evaluate("JSON.stringify({url:location.href,state:document.readyState,body:document.body?.innerText.slice(0,600)})")}`,
      );
    }
  }
  for (const name of ["terrain-generation", "trail-layout"]) {
    console.log(`Checking article: ${name}`);
    await visit(`/wiki/${name}.html`);
    await until(
      () =>
        evaluate(
          "!!document.querySelector('#search .pagefind-ui__search-input')",
        ),
      "search without CDN",
    );
    await evaluate(
      "document.querySelector('.gallery').scrollIntoView({block:'center'})",
    );
    await until(
      () =>
        evaluate(
          "[...document.images].every(i => i.complete && i.naturalWidth > 0)",
        ),
      "local gallery images",
    );
    await evaluate("document.querySelector('.carousel-wrap .next').click()");
    await until(
      () => evaluate("document.querySelector('.carousel').scrollLeft > 0"),
      "next gallery image",
    );
    await evaluate("document.querySelector('.carousel-wrap .prev').click()");
    await until(
      () => evaluate("document.querySelector('.carousel').scrollLeft < 1"),
      "previous gallery image",
    );
    await evaluate("document.fonts.ready");
    assert.ok(
      await evaluate("document.fonts.check('19px \"Libertinus Serif\"')"),
    );
    for (const width of [1440, 480]) {
      await cdp("Emulation.setDeviceMetricsOverride", {
        width,
        height: 1000,
        deviceScaleFactor: 1,
        mobile: false,
      });
      assert.ok(
        await evaluate("document.documentElement.scrollWidth <= innerWidth"),
        `overflow: ${name}, ${width}`,
      );
    }
  }
  for (const theme of ["light", "dark", "system"]) {
    await evaluate("document.querySelector('#theme-toggle').click()");
    assert.equal(
      await evaluate("document.querySelector('#theme-toggle').textContent"),
      `Theme: ${theme}`,
    );
  }
  assert.ok(
    await evaluate(
      "document.querySelector('main .related-documents').previousElementSibling.getAttribute('role') === 'doc-endnotes'",
    ),
  );
  for (const collection of ["wiki", "documents"]) {
    const urls = await evaluate(
      `(async () => { const pf = await import('/${collection}/pagefind/pagefind.js'); const found = await pf.search('terrain'); return Promise.all(found.results.map(async r => (await r.data()).url)); })()`,
    );
    assert.ok(urls.length > 0);
    assert.ok(
      urls.every((url) =>
        new URL(url, base).pathname.startsWith(`/${collection}/`),
      ),
    );
  }
  for (const [name, path] of [
    ["terrain-generation", "/wiki/terrain-generation.html"],
    [
      "quell-hex-terrain-r11-design",
      "/documents/quell-hex-terrain-r11-design.html",
    ],
  ]) {
    const info = await fetch(`${base}/api/src?page=${name}`).then((r) =>
      r.json(),
    );
    assert.equal(info.url, path);
    assert.ok(info.path.includes("/src/"));
    await visit(`/editor/?page=${name}`, ".cm-editor");
    assert.equal(
      await evaluate(
        "new URL(document.querySelector('#preview').src).pathname",
      ),
      path,
    );
  }
  const valid =
    '#import "../../template.typ": *\n#show: article.with(title: [Browser fixture])\nInitial content.\n';
  writeFileSync(fixture, valid);
  const info = await until(async () => {
    const r = await fetch(`${base}/api/src?page=zz-browser-test`);
    return r.ok && r.json();
  }, "source discovery");
  const response = await fetch(`${base}/api/src?page=zz-browser-test`, {
    method: "POST",
    body: JSON.stringify({
      mtime: info.mtime,
      text: valid.replace("Initial", "Updated"),
    }),
  });
  assert.equal(response.status, 200);
  await until(
    async () =>
      (
        await fetch(`${base}/wiki/zz-browser-test.html`).then((r) => r.text())
      ).includes("Updated content"),
    "saved preview",
  );
  assert.equal(
    (
      await fetch(`${base}/api/src?page=zz-browser-test`, {
        method: "POST",
        body: JSON.stringify({ mtime: info.mtime, text: valid }),
      })
    ).status,
    409,
  );
  writeFileSync(fixture, valid + '\n#doc("trail-layout")\n');
  await until(
    async () =>
      (await fetch(`${base}/api/build`).then((r) => r.json())).error?.includes(
        "unknown document",
      ),
    "invalid reference rejected",
  );
  assert.ok(
    (
      await fetch(`${base}/wiki/zz-browser-test.html`).then((r) => r.text())
    ).includes("Updated content"),
  );
  rmSync(fixture);
  await until(
    () => !existsSync(join(root, "out/wiki/zz-browser-test.html")),
    "removed page cleaned up",
  );
  await cdp("Page.navigate", {
    url: base + "/pta-atip-algorithm.html#pta-atip-algorithm-background",
  });
  await until(
    () =>
      evaluate(
        "location.pathname === '/documents/pta-atip-algorithm.html' && location.hash === '#pta-atip-algorithm-background'",
      ),
    "legacy section redirect",
  );
  console.log(
    "PASS: local images/fonts, galleries, theme cycle, responsive layout, separate search, both editors, saves, last-good builds and legacy redirects",
  );
} catch (error) {
  console.error(logs);
  throw error;
} finally {
  rmSync(fixture, { force: true });
  socket?.close();
  const stopped = [];
  for (const process of [chrome, vite]) {
    if (process && process.exitCode === null) {
      stopped.push(new Promise((resolve) => process.once("exit", resolve)));
      process.kill();
    }
  }
  await Promise.all(stopped);
  rmSync(temporary, { recursive: true, force: true });
}
