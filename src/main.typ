// Build the Quell wiki and document library as separate reading collections.
// Only the source catalogue, editor and rendering helpers are shared.
#import "template.typ": *
#import "topic.typ": topic-page

/// Preserve old record URLs without indexing duplicate copies of their bodies.
#let redirect(url) = {
  html.elem(
    "script",
    "location.replace(" + repr(url) + " + location.search + location.hash);",
  )
  html.elem("noscript")[
    #html.elem("meta", attrs: (http-equiv: "refresh", content: "0;url=" + url))
  ]
  html.elem("p")[This page moved to #link(url)[#url].]
}

#for p in manifest.pages {
  document(p.url.slice(1), {
    current.update(p.name)
    include "../" + p.path
  })
  if p.kind == "document" {
    document(p.name + ".html", redirect(p.url))
  }
}

/// Reference records that became wiki articles keep their old document URLs.
#for p in manifest.pages.filter(p => (
  p.kind == "article"
    and (p.name.starts-with("explainer-") or p.name == "glossary")
)) {
  document("documents/" + p.name + ".html", redirect(p.url))
  document(p.name + ".html", redirect(p.url))
}

// The explainers area became NLP articles.
#document("documents/explainers.html", redirect("/wiki/nlp.html"))
#document("explainers.html", redirect("/wiki/nlp.html"))

#document("wiki/index.html", title: [qproj wiki], include "wiki/index.typ")
#document("wiki/maintenance.html", title: [Maintenance], shell(
  [Maintenance],
  maintenance(),
  collection: "wiki",
))
#document("documents/index.html", title: [Document library], shell(
  [Document library],
  home(),
))
#document("documents/status.html", title: [Document status], shell(
  [Document status],
  status-index(),
))
#document("index.html", redirect("/wiki/index.html"))
#document("status.html", redirect("/documents/status.html"))
#for a in areas {
  document("documents/" + a.id + ".html", title: a.title, shell(
    a.title,
    area-index(a),
  ))
  document(a.id + ".html", redirect("/documents/" + a.id + ".html"))
}

#for collection in ("wiki", "documents") {
  document(collection + "/search.html", title: [Search], shell(
    [Search],
    [
      #html.elem("p", attrs: (
        id: "search-status",
        role: "status",
      ))[Enter a search above.]
      #html.elem("ol", attrs: (
        id: "search-results",
        data-index: "/" + collection + "/pagefind/pagefind.js",
        data-merge: if collection == "wiki" { "/documents/pagefind/" } else {
          "/wiki/pagefind/"
        },
      ))
      #html.elem("noscript")[Search requires JavaScript.]
      #html.elem("script", attrs: (
        type: "module",
        src: "/web/scripts/search.js",
      ))
    ],
    collection: collection,
  ))
}

// Topics reuse authored article metadata without becoming searchable articles.
#context {
  let portals = all-pages().filter(p => p.kind == "portal")
  let urls = ()
  for portal in portals {
    for (label, pages) in topic-groups(portal.area) {
      let url = topic-url(portal.area, label)
      assert(
        url not in urls and url not in manifest.pages.map(p => p.url),
        message: "duplicate topic URL: " + url,
      )
      urls.push(url)
      document(url.slice(1), title: [Topic: #topic-name(label)], topic-page(
        portal,
        label,
        pages,
      ))
    }
  }
}
