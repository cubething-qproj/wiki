/// <reference types="vite/client" />

// The wiki's page editor: CodeMirror with Vim keys and Typst highlighting on
// the left, the built page on the right. Opened as /editor/?page=<name>.
//
// Saving writes the source through /api/src. The dev server rebuilds, and the
// preview reloads itself on the `wiki:built` event (see vite.config.mts). With
// autosave on, the editor saves after a short pause in typing; `:w` always
// saves. tinymist, through the /lsp WebSocket, supplies diagnostics,
// completions and hover. Without it the editor still works.

import { oneDark } from "@codemirror/theme-one-dark";
import {
  languageServerExtensions,
  LSPClient,
  type Transport,
} from "@codemirror/lsp-client";
import { Vim, vim } from "@replit/codemirror-vim";
import { basicSetup, EditorView } from "codemirror";
import { typst_lezer } from "codemirror-lang-typst/lezer";

const AUTOSAVE_DELAY_MS = 300;

const page = new URLSearchParams(location.search).get("page") ?? "index";
const $ = (id: string) => document.getElementById(id) as HTMLElement;
const status = $("status");
const autosave = $("autosave") as HTMLInputElement;

/** Show a short status; errors stay highlighted until the next status. */
function setStatus(text: string, error = false) {
  status.textContent = text;
  status.classList.toggle("error", error);
}

/** Open a WebSocket transport for the LSP client, or null if it can't connect. */
function connectLsp(url: string): Promise<Transport | null> {
  return new Promise((resolve) => {
    let handlers: ((message: string) => void)[] = [];
    const socket = new WebSocket(url);
    socket.onmessage = (event) => {
      for (const handler of handlers) handler(String(event.data));
    };
    socket.onerror = () => resolve(null);
    socket.onopen = () =>
      resolve({
        send: (message) => socket.send(message),
        subscribe: (handler) => handlers.push(handler),
        unsubscribe: (handler) => {
          handlers = handlers.filter((h) => h !== handler);
        },
      });
  });
}

const source = await fetch(`/api/src?page=${encodeURIComponent(page)}`).then(
  (r) => r.json(),
);
if (source.error) throw new Error(`${page}: ${source.error}`);
let mtime: number = source.mtime;
let conflict = false;

$("name").textContent = page;
($("view") as HTMLAnchorElement).href = source.url;
($("preview") as HTMLIFrameElement).src = source.url;
document.title = `edit: ${page}`;
autosave.checked = localStorage.getItem("wiki:autosave") !== "false";
autosave.onchange = () =>
  localStorage.setItem("wiki:autosave", String(autosave.checked));

/** Write the editor's text to the page's file, unless it changed on disk. */
async function save() {
  if (conflict) return;
  setStatus("saving…");
  const response = await fetch(`/api/src?page=${encodeURIComponent(page)}`, {
    method: "POST",
    body: JSON.stringify({ text: view.state.doc.toString(), mtime }),
  });
  const result = await response.json();
  if (response.status === 409) {
    conflict = true;
    setStatus(
      "the file changed on disk; not saved. Copy your text and reload.",
      true,
    );
  } else if (!response.ok) {
    setStatus(`not saved: ${result.error}`, true);
  } else {
    mtime = result.mtime;
    setStatus("saved, building…");
  }
}

let timer: ReturnType<typeof setTimeout> | undefined;
const autosaveOnChange = EditorView.updateListener.of((update) => {
  if (!update.docChanged || !autosave.checked) return;
  clearTimeout(timer);
  timer = setTimeout(save, AUTOSAVE_DELAY_MS);
});
Vim.defineEx("write", "w", () => save());

const transport = await connectLsp(`ws://${location.host}/lsp`);
const lsp = transport
  ? new LSPClient({
      rootUri: `file://${source.root}`,
      extensions: languageServerExtensions(),
    })
      .connect(transport)
      .plugin(`file://${source.path}`, "typst")
  : [];
if (!transport)
  setStatus("tinymist unavailable: no diagnostics or completions");

const view = new EditorView({
  doc: source.text,
  parent: $("editor"),
  extensions: [
    vim(),
    basicSetup,
    typst_lezer(),
    EditorView.lineWrapping,
    document.documentElement.classList.contains("dark") ? oneDark : [],
    autosaveOnChange,
    lsp,
  ],
});
view.focus();

/** Show a build result: the error under the editor, or nothing. */
function showBuild(result: { error?: string }) {
  const error = $("error");
  error.hidden = !result.error;
  error.textContent = result.error ?? "";
  if (result.error)
    setStatus("build failed; the preview shows the last good build", true);
  else if (!conflict) setStatus("built");
}
import.meta.hot?.on("wiki:built", showBuild);
fetch("/api/build")
  .then((r) => r.json())
  .then((result) => result.error && showBuild(result));
