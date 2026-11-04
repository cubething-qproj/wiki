// Shared rendering for Quell's wiki and separate document library.
// Sources live under src/wiki, src/documents and src/reference.
// The browser frontend lives in web/; public images and fonts live in static/.
// See ../README.md for authoring conventions and stable IDs.

// ---- data ----

/// Every page file, its area and date. Written by `scripts/manifest.py`.
#let manifest = json("../manifest.json")

/// The areas, in display order. Each is a directory of pages.
#let areas = (
  (id: "project", title: [Project overview], about: [How Quell's repositories, crates and labs fit together.]),
  (id: "nlp", title: [NLP and argumentation], about: [Argument mining, PTA and IAT, debate.]),
  (id: "pcg", title: [Procedural generation], about: [Terrain, hex boards, world generation.]),
  (
    id: "gameplay-3d",
    title: [Gameplay: physics and 3D world],
    about: [Camera, character controller, world interaction.],
  ),
  (id: "gameplay-vn", title: [Gameplay: visual novel], about: [The visual novel games.]),
  (id: "narrative", title: [Narrative and writing], about: [Story, characters, dialogue.]),
  (id: "graphics", title: [Graphics], about: [Rendering, shaders, look.]),
  (id: "engine", title: [Engine: q_os and libraries], about: [The `lib/` crates.]),
  (id: "tooling", title: [Tooling], about: [Development environment and workflow.]),
  (id: "reference", title: [Reference], about: [Papers and reference notes.]),
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

// ---- links ----

/// The manifest entry for a page by name.
#let entry(name) = manifest.pages.find(p => p.name == name)

/// An authored page or generated document index's collection-qualified URL.
#let page-url(name) = {
  let e = entry(name)
  if e == none { "/documents/" + name + ".html" } else { e.url }
}


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
  let href = page-url(name) + if parts.len() > 1 { "#" + parts.at(1) } else { "" }
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

// ---- media ----

/// A locally hosted image with meaningful alt text, an optional caption, and
/// a full-resolution link. Used directly or as an item in `gallery`.
#let media(url, alt: "", caption: none) = html.elem("figure")[
  #link(url, html.elem("img", attrs: (src: url, alt: alt, loading: "lazy")))
  #if caption != none { html.elem("figcaption", caption) }
]

/// A scroll-snap image gallery, adapted from the blog's carousel. Images stay
/// linked to their originals; touch/keyboard scrolling works without scripts.
#let gallery(caption: none, ..items) = html.elem("figure", attrs: (class: "gallery"))[
  #html.elem("div", attrs: (class: "carousel-wrap"))[
    #html.elem("button", attrs: (class: "prev", type: "button", aria-label: "Previous image"))[‹]
    #html.elem("ul", attrs: (class: "carousel", tabindex: "0", aria-label: "Image gallery"))[
      #for item in items.pos() { html.elem("li", item) }
    ]
    #html.elem("button", attrs: (class: "next", type: "button", aria-label: "Next image"))[›]
  ]
  #if caption != none { html.elem("figcaption", caption) }
]

// ---- callouts ----

/// An emoji, a visible type heading, and text, shared by all callout helpers.
#let callout(kind: "note", icon: "📝", body) = html.elem("aside", attrs: (class: "callout"))[
  #html.elem("div", attrs: (class: "callout-title"))[#icon #upper(kind.slice(0, 1))#kind.slice(1)]
  #body
]

/// Mark an unresolved question without turning an article into a proceedings log.
#let undecided(body) = callout(kind: "undecided", icon: "🤔", body)

/// A short explanation linking to a supporting explainer document.
#let explain(name, title, body) = callout(kind: "explanation", icon: "💡")[
  *#title.* #body #l("explainer-" + name)[More →]
]

/// Preserve existing decision call sites using the common callout presentation.
#let decide(body) = callout(kind: "decision", icon: "📌", body)

/// Compatibility for older documents' open-question callouts.
#let open(body) = undecided(body)

/// An in-page anchor for `#id` links; Typst labels don't emit ids in HTML.
#let anchor(id) = html.elem("span", attrs: (id: id))

/// A muted one-line note, e.g. under a page title.
#let note(body) = html.elem("p", attrs: (class: "note"), body)

/// A status badge.
#let badge(status) = html.elem("span", attrs: (class: "badge " + status), status)

// ---- page shells ----

/// Initialize the collection's search and place native endnotes before its footer.
/// The two Pagefind indexes are built by `just build` or the dev server.

#let nav(collection) = html.elem("header")[
  #link("/" + collection + "/index.html", html.elem("span", attrs: (class: "collection"), if collection == "wiki" {
    [Quell wiki]
  } else { [Documents] }))
  #if collection == "documents" { link("/documents/status.html")[status] }
  #link(if collection == "wiki" { "/documents/index.html" } else { "/wiki/index.html" })[
    #if collection == "wiki" { [Document library ↗] } else { [Quell wiki ↗] }
  ]
  #html.elem("button", attrs: (id: "theme-toggle", type: "button", aria-label: "Cycle color theme"))[Theme: system]
  #html.elem("div", attrs: (id: "search"))
]

/// Styles, nav, title and the Mermaid and search loaders around a body. Used
/// directly by generated pages; authored pages go through `wiki-page`. Only
/// `indexed` pages are searchable, so search finds pages, not the indexes
/// that list them.
#let shell(title, body, indexed: false, collection: "documents") = {
  // Bundle documents share counters unless each page explicitly starts afresh.
  for target in (
    heading,
    footnote,
    math.equation,
    figure.where(kind: image),
    figure.where(kind: table),
    figure.where(kind: raw),
    figure.where(kind: "video"),
  ) {
    counter(target).update(0)
  }
  show raw.where(lang: "mermaid"): mermaid-block
  let search-root = "/" + collection + "/pagefind/"
  html.elem("link", attrs: (rel: "stylesheet", href: search-root + "pagefind-ui.css"))
  html.elem("script", attrs: (src: "/web/scripts/theme.js"))
  html.elem("link", attrs: (rel: "stylesheet", href: "/web/styles/palette.css"))
  html.elem("link", attrs: (rel: "stylesheet", href: "/web/styles/main.css"))
  nav(collection)
  html.elem("main", attrs: (class: collection) + if indexed { (data-pagefind-body: "") } else { (:) })[
    #html.elem("h1", title)
    #body
  ]
  html.elem("script", attrs: (type: "module", src: "/web/scripts/mermaid.js"))
  // A classic script, not an import, so Vite serves it untouched.
  html.elem("script", attrs: (src: search-root + "pagefind-ui.js"))
  html.elem("script", attrs: (src: "/web/scripts/main.js", defer: ""))
}

/// Link explicitly to a document, rejecting article IDs and unknown records.
#let doc(target, ..label) = context {
  let name = target.split("#").first()
  let e = entry(name)
  assert(e != none and e.kind == "document", message: "unknown document: " + name)
  l(target, ..label)
}

/// Mark something designed but not yet implemented, citing the records that describe it:
/// `#wip("debate-game")`, or `#wip("debate-game")[Extra detail.]`.
#let wip(..args) = {
  let names = args.pos().filter(a => type(a) == str)
  let extra = args.pos().filter(a => type(a) == content)
  callout(kind: "WIP", icon: "⚒️")[
    This is not yet implemented.
    #if names.len() > 0 [See #names.map(n => doc(n)).join(", ", last: " and ").]
    #extra.join()
  ]
}

/// Pages that link to `name`, excluding itself and generated indexes.
/// Wiki backlinks include articles only, not procedural records.
#let backlinks(name) = {
  query(<wikilink>)
    .filter(m => m.value.to == name and m.value.from != name and m.value.from not in generated)
    .map(m => m.value.from)
    .dedup()
    .filter(n => entry(name).kind == "document" or entry(n).kind == "article")
    .map(n => link(page-url(n), title-of(n)))
}

/// Explicitly selected documents, newest edited first, with stable tie ordering.
#let related-documents(names) = context {
  // Record the relation before query-dependent display and date ordering.
  for name in names.dedup() { record-link(name) }
  let records = names
    .dedup()
    .map(name => {
      let e = entry(name)
      assert(e != none and e.kind == "document", message: "unknown document: " + name)
      let page = query(<wiki-page>).find(m => m.value.name == name)
      (entry: e, page: if page == none { none } else { page.value })
    })
    .sorted(key: r => r.entry.name)
    .sorted(key: r => r.entry.edited)
    .rev()
  html.elem("section", attrs: (class: "related-documents"))[
    #html.elem("h2")[Related documents]
    #for r in records {
      html.elem("p")[
        #link(r.entry.url, title-of(r.entry.name))
        #if r.page != none { [ · #r.page.document-type · #badge(r.page.status)] }
        #html.elem("span", attrs: (class: "meta"))[ · edited #r.entry.date]
      ]
    }
  ]
}

/// Insert a generated, page-scoped contents block, normally after the lead.
#let contents() = context {
  let name = current.get()
  let id = if name == none { "standalone" } else { name }
  html.elem("details", attrs: (class: "contents", open: ""))[
    #html.elem("summary")[Contents]
    #outline(
      title: none,
      target: selector(heading).after(label("article-start-" + id)).before(label("article-end-" + id)),
    )
  ]
}

/// The show rule for an authored page: sets the title, records the page's
/// metadata for indexes, and adds a status line and backlinks.
#let wiki-page(
  title: none,
  status: "draft",
  summary: none,
  document-type: none,
  documents: (),
  is-article: false,
  body,
) = {
  if not is-article { assert(status in statuses, message: "unknown status: " + status) }
  set document(title: title)
  context {
    let name = current.get()
    let collection = if is-article { "wiki" } else { "documents" }
    let e = if name == none { none } else { entry(name) }
    let kind = if e == none { collection } else { e.kind }
    let area = if e == none { none } else { areas.find(a => a.id == e.area) }
    let type = if document-type != none { document-type } else if e != none and e.path.starts-with("src/reference/") {
      "reference"
    } else { "design" }
    if e != none {
      assert(is-article == (e.kind != "document"), message: "page uses the wrong collection template: " + name)
      [#metadata((
        name: name,
        area: e.area,
        kind: e.kind,
        title: title,
        status: status,
        document-type: type,
        summary: summary,
      )) <wiki-page>]
    }
    shell(
      title,
      {
        if e != none {
          html.elem("p", attrs: (class: "meta"))[
            #if not is-article { [#type · #badge(status) · ] }
            #if area != none {
              let portal = "portal-" + e.area
              link(
                if is-article { if entry(portal) == none { "/wiki/index.html" } else { page-url(portal) } } else {
                  page-url(e.area)
                },
                area.title,
              )
            }
            #if not is-article { [ · edited #e.date] }
            · #link("/editor/?page=" + name)[Edit]
          ]
        }
        if is-article and kind != "portal" {
          // Queries span the bundle: markers keep this outline inside one article.
          let start = "article-start-" + if name == none { "standalone" } else { name }
          let end = "article-end-" + if name == none { "standalone" } else { name }
          [#metadata(none)#label(start)]
          body
          [#metadata(none)#label(end)]
        } else { body }
        if is-article and documents.len() > 0 { related-documents(documents) }
        if e != none {
          // Isolate the query so updating backlinks does not recreate body links.
          context {
            let from = backlinks(name)
            if from.len() > 0 {
              html.elem("p", attrs: (class: "backlinks"))[What links here: #from.join(", ")]
            }
          }
        }
      },
      indexed: e != none and kind != "portal",
      collection: collection,
    )
  }
}

/// A maintained Quell article, without procedural lifecycle badges.
/// `documents` selects supporting record IDs, sorted by their actual edit times.
#let article(title: none, summary: none, documents: (), body) = wiki-page(
  title: title,
  summary: summary,
  documents: documents,
  is-article: true,
  body,
)

// ---- generated pages ----

/// All authored pages' metadata, with their manifest dates. Needs context.
#let all-pages() = query(<wiki-page>).map(m => m.value + (date: entry(m.value.name).date))

/// Generated topic inventory for an authored portal, without procedural records.
#let article-list(area) = context {
  for p in all-pages().filter(p => p.kind == "article" and p.area == area).sorted(key: p => p.name) {
    html.elem("p")[#link(page-url(p.name), p.title) — #p.summary]
  }
}

/// The article collection's landing page, with authored portals and topic links.
#let wiki-home() = context {
  [Quell is a game in development, built with Bevy. The plan is for its players
    to explore generated landscapes, read real philosophy found along the way, and
    debate the characters they meet. Start with a portal or a topic below.]
  let portals = all-pages().filter(p => p.kind == "portal")
  for p in portals { html.elem("p")[*#link(page-url(p.name), p.title)* — #p.summary] }
  html.elem("h2")[Articles]
  for p in all-pages().filter(p => p.kind == "article").sorted(key: p => p.name) {
    html.elem("p")[#link(page-url(p.name), p.title) — #p.summary]
  }
}

/// A table of pages: title, status, summary, date.
#let page-table(pages) = table(
  columns: (auto, auto, 1fr, auto),
  ..pages
    .map(p => (
      link(page-url(p.name), p.title),
      badge(p.status),
      p.summary,
      html.elem("span", attrs: (class: "date"), p.date),
    ))
    .flatten(),
)

/// One area's index: its current pages, then its history.
#let area-index(area) = context {
  let pages = all-pages().filter(p => p.kind == "document" and p.area == area.id).sorted(key: p => p.name)
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
  let pages = all-pages().filter(p => p.kind == "document")
  [The document library: proposals, reference material and historical records. Topic explanations live in the #link("/wiki/index.html")[Quell wiki]. Unconverted plans, handoffs and issues remain in `.docs/`.]
  table(
    columns: (auto, 1fr, auto),
    ..areas.map(a => (link(page-url(a.id), a.title), a.about, str(pages.filter(p => p.area == a.id).len()))).flatten(),
  )
  [== Recent changes]
  page-table(pages.sorted(key: p => p.date).rev().slice(0, calc.min(12, pages.len())))
}

/// Every page grouped by status.
#let status-index() = context {
  let pages = all-pages().filter(p => p.kind == "document")
  for s in statuses {
    let these = pages.filter(p => p.status == s).sorted(key: p => p.name)
    if these.len() > 0 [
      == #s
      #page-table(these)
    ]
  }
}
