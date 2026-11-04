// Shared template for the qproj design wiki.
//
// Pages are `.typ` files in an area directory (`nlp/`, `pcg/`, …). Each one
// starts with
//
//   #import "../_template.typ": *
//   #show: wiki-page.with(title: [...], status: "current", summary: [...])
//
// `main.typ` turns every page listed in `manifest.json` into `<name>.html`,
// and adds the generated pages: home (`index`), one index per area, and
// `status`. Link between pages with `#l("name")` or `#l("name")[label]`; an
// unknown name fails the build. Links are recorded as `<wikilink>` metadata,
// which is how each page lists what links to it.
//
// Mermaid blocks render client-side; `click NODE href "page.html"` links are
// checked and recorded like `l()`. `style` and `script` bodies must be
// strings, not content.

// ---- data ----

/// Every page file, its area and date. Written by `scripts/manifest.py`.
#let manifest = json("manifest.json")

/// The areas, in display order. Each is a directory of pages.
#let areas = (
  (id: "nlp", title: [NLP and argumentation], about: [Argument mining, PTA and IAT, debate.]),
  (id: "pcg", title: [Procedural generation], about: [Terrain, hex boards, world generation.]),
  (id: "gameplay-3d", title: [Gameplay: physics and 3D world], about: [Camera, character controller, world interaction.]),
  (id: "gameplay-vn", title: [Gameplay: visual novel], about: [The visual novel games.]),
  (id: "narrative", title: [Narrative and writing], about: [Story, characters, dialogue.]),
  (id: "graphics", title: [Graphics], about: [Rendering, shaders, look.]),
  (id: "engine", title: [Engine: q_os and libraries], about: [The `lib/` crates.]),
  (id: "tooling", title: [Tooling], about: [Development environment and workflow.]),
  (id: "reference", title: [Reference], about: [Papers and reference notes.]),
  (id: "explainers", title: [Explainers], about: [One short page per technical term.]),
)

/// Page statuses. The first two are "current"; the rest are history.
#let statuses = ("draft", "current", "done", "superseded", "retired", "wont-do")
#let history = ("done", "superseded", "retired", "wont-do")

/// Titles of the pages `main.typ` generates.
#let generated = (index: [Home], status: [Status]) + areas.map(a => (a.id, a.title)).to-dict()

/// Every valid link target.
#let known = manifest.pages.map(p => p.name) + generated.keys()

/// The name of the page being built; `main.typ` sets it before each page.
#let current = state("wiki-current", none)

// ---- styles and scripts ----

#let css = "
:root { color-scheme:light dark; --bg:#fbfaf7; --fg:#1f2328; --muted:#636c76; --line:#d0d7de;
  --link:#0b63ce; --explain:#eaf3ff; --explain-bar:#3b82f6;
  --decide:#fff5e0; --decide-bar:#d97706; --open:#f3eefe; --open-bar:#7c3aed; }
@media (prefers-color-scheme: dark) {
  :root { --bg:#16181d; --fg:#e6e6e6; --muted:#9aa4af; --line:#30363d;
    --link:#6cb6ff; --explain:#14263d; --explain-bar:#3b82f6;
    --decide:#33270f; --decide-bar:#d97706; --open:#251a3d; --open-bar:#a78bfa; } }
body { background:var(--bg); color:var(--fg); margin:0;
  font:17px/1.55 system-ui, sans-serif; }
header { border-bottom:1px solid var(--line); padding:.6rem 1rem; font-size:.95rem;
  display:flex; align-items:center; gap:1rem; position:relative; }
#search { margin-left:auto; width:min(26rem, 55vw); --pagefind-ui-scale:.75;
  --pagefind-ui-background:var(--bg); --pagefind-ui-text:var(--fg);
  --pagefind-ui-border:var(--line); --pagefind-ui-primary:var(--link); }
#search .pagefind-ui__drawer { position:absolute; right:1rem; width:min(36rem, 90vw); z-index:10;
  background:var(--bg); border:1px solid var(--line); padding:0 1rem; max-height:70vh; overflow:auto; }
#search .pagefind-ui__drawer:empty { display:none; }
main { max-width:46rem; margin:0 auto; padding:1rem 1.2rem 4rem; }
a { color:var(--link); }
h1 { font-size:1.7rem; margin-bottom:.3rem; }
h2 { font-size:1.25rem; margin-top:2rem; }
code { font-size:.9em; }
pre:not(.mermaid) { background:var(--explain); padding:.7rem; overflow-x:auto; font-size:.85rem; }
pre.mermaid { background:none; text-align:center; }
table { border-collapse:collapse; width:100%; font-size:.95rem; }
td, th { border:1px solid var(--line); padding:.3rem .5rem; vertical-align:top; text-align:left; }
.date { white-space:nowrap; }
aside { padding:.6rem .9rem; margin:1rem 0; border-left:4px solid; }
aside.explain { background:var(--explain); border-color:var(--explain-bar); }
aside.decide { background:var(--decide); border-color:var(--decide-bar); }
aside.open { background:var(--open); border-color:var(--open-bar); }
.note, .meta, .backlinks { color:var(--muted); font-size:.9rem; }
.backlinks { border-top:1px solid var(--line); margin-top:3rem; padding-top:.6rem; }
.badge { font-size:.75rem; padding:.05rem .45rem; border-radius:.6rem; border:1px solid var(--line);
  white-space:nowrap; }
.badge.draft { border-color:#d97706; } .badge.current { border-color:#16a34a; }
.badge.done { border-color:#3b82f6; }
.badge.superseded, .badge.retired, .badge.wont-do { color:var(--muted); }
"

#let mermaid-js = "
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs';
const dark = matchMedia('(prefers-color-scheme: dark)').matches;
mermaid.initialize({ startOnLoad: true, securityLevel: 'loose', deterministicIds: true, theme: dark ? 'dark' : 'default' });
"

// ---- links ----

/// The title of a page by name. Needs context.
#let title-of(name) = if name in generated {
  generated.at(name)
} else {
  let found = query(<wiki-page>).find(m => m.value.name == name)
  if found == none { name } else { found.value.title }
}

/// Fail the build if `name` isn't a page, and record a link to it.
#let record-link(name) = {
  if name not in known { panic("unknown wiki page: " + name) }
  [#metadata((from: current.get(), to: name)) <wikilink>]
}

/// Link to a wiki page: `#l("debate-spike")`, `#l("debate-spike")[the spike]`,
/// or with an anchor, `#l("debate-pipeline#s3")`. With no label, the target's
/// title is used. Unknown pages fail the build.
#let l(target, ..label) = context {
  let parts = target.split("#")
  let name = parts.first()
  record-link(name)
  let href = name + ".html" + if parts.len() > 1 { "#" + parts.at(1) } else { "" }
  link(href, label.pos().at(0, default: title-of(name)))
}

/// A Mermaid block: links in `click … href "x.html"` lines are checked and
/// recorded, then the diagram is left for the browser to render.
#let mermaid-block(it) = context {
  for m in it.text.matches(regex("href \"([^\"#]+)\\.html")) {
    record-link(m.captures.first())
  }
  html.elem("pre", attrs: (class: "mermaid"), it.text)
}

// ---- callouts ----

/// A short inline explanation that links to the full explainer page.
#let explain(name, title, body) = html.elem("aside", attrs: (class: "explain"))[
  *#title.* #body #l("explainer-" + name)[More →]
]

/// A decision that has been made, or is waiting on Ada.
#let decide(body) = html.elem("aside", attrs: (class: "decide"))[*Decision:* #body]

/// A question that is open and not yet designed.
#let open(body) = html.elem("aside", attrs: (class: "open"))[*Open:* #body]

/// An in-page anchor for `#id` links; Typst labels don't emit ids in HTML.
#let anchor(id) = html.elem("span", attrs: (id: id))

/// A muted one-line note, e.g. under a page title.
#let note(body) = html.elem("p", attrs: (class: "note"), body)

/// A status badge.
#let badge(status) = html.elem("span", attrs: (class: "badge " + status), status)

// ---- page shells ----

/// Loads Pagefind's search UI into `#search`. The index is built by
/// `pagefind --site out` into `out/pagefind/`, so it only exists after a full
/// `just build` or under `just serve`.
#let search-js = "
addEventListener('DOMContentLoaded', () => {
  if (window.PagefindUI) new PagefindUI({ element: '#search', showSubResults: true, resetStyles: false });
});
"

#let nav = html.elem("header")[
  #link("index.html")[home]
  #link("explainers.html")[explainers]
  #link("status.html")[status]
  #html.elem("div", attrs: (id: "search"))
]

/// Styles, nav, title and the Mermaid and search loaders around a body. Used
/// directly by generated pages; authored pages go through `wiki-page`. Only
/// `indexed` pages are searchable, so search finds pages, not the indexes
/// that list them.
#let shell(title, body, indexed: false) = {
  show raw.where(lang: "mermaid"): mermaid-block
  html.elem("link", attrs: (rel: "stylesheet", href: "pagefind/pagefind-ui.css"))
  html.elem("style", css)
  nav
  html.elem("main", attrs: if indexed { (data-pagefind-body: "") } else { (:) })[
    #html.elem("h1", title)
    #body
  ]
  html.elem("script", attrs: (type: "module"), mermaid-js)
  // A classic script, not an import, so Vite serves it untouched.
  html.elem("script", attrs: (src: "pagefind/pagefind-ui.js"))
  html.elem("script", search-js)
}

/// The manifest entry for a page by name.
#let entry(name) = manifest.pages.find(p => p.name == name)

/// Pages that link to `name`, as links, excluding itself. Needs context.
#let backlinks(name) = {
  query(<wikilink>)
    .filter(m => m.value.to == name and m.value.from != name and m.value.from not in generated)
    .map(m => m.value.from)
    .dedup()
    .map(n => link(n + ".html", title-of(n)))
}

/// The show rule for an authored page: sets the title, records the page's
/// metadata for indexes, and adds a status line and backlinks.
#let wiki-page(title: none, status: "draft", summary: none, body) = {
  assert(status in statuses, message: "unknown status: " + status)
  set document(title: title)
  context {
    let name = current.get()
    let e = entry(name)
    let area = areas.find(a => a.id == e.area)
    [#metadata((name: name, area: e.area, title: title, status: status, summary: summary)) <wiki-page>]
    shell(title, {
      html.elem("p", attrs: (class: "meta"))[
        #badge(status) · #link(e.area + ".html", if area == none { e.area } else { area.title }) · changed #e.date
      ]
      body
      let from = backlinks(name)
      if from.len() > 0 {
        html.elem("p", attrs: (class: "backlinks"))[What links here: #from.join(", ")]
      }
    }, indexed: true)
  }
}

// ---- generated pages ----

/// All authored pages' metadata, with their manifest dates. Needs context.
#let all-pages() = query(<wiki-page>).map(m => m.value + (date: entry(m.value.name).date))

/// A table of pages: title, status, summary, date.
#let page-table(pages) = table(
  columns: (auto, auto, 1fr, auto),
  ..pages.map(p => (link(p.name + ".html", p.title), badge(p.status), p.summary, html.elem("span", attrs: (class: "date"), p.date))).flatten(),
)

/// One area's index: its current pages, then its history.
#let area-index(area) = context {
  let pages = all-pages().filter(p => p.area == area.id).sorted(key: p => p.name)
  let now = pages.filter(p => p.status not in history)
  let old = pages.filter(p => p.status in history)
  area.about
  if pages.len() == 0 [ No pages yet. ]
  if now.len() > 0 { page-table(now) }
  if old.len() > 0 [
    == History
    #page-table(old)
  ]
}

/// The home page: areas, then recent changes.
#let home() = context {
  let pages = all-pages()
  [The qproj design wiki. Plans, handoffs and issues live in `.docs/` outside it.]
  table(
    columns: (auto, 1fr, auto),
    ..areas
      .map(a => (link(a.id + ".html", a.title), a.about, str(pages.filter(p => p.area == a.id).len())))
      .flatten(),
  )
  [== Recent changes]
  page-table(pages.sorted(key: p => p.date).rev().slice(0, calc.min(12, pages.len())))
}

/// Every page grouped by status.
#let status-index() = context {
  let pages = all-pages()
  for s in statuses {
    let these = pages.filter(p => p.status == s).sorted(key: p => p.name)
    if these.len() > 0 [
      == #s
      #page-table(these)
    ]
  }
}
