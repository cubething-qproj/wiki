// Build the Quell wiki and document library as separate reading collections.
// Only the source catalogue, editor and rendering helpers are shared.
#import "template.typ": *

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

#document("wiki/index.html", title: [Quell wiki], include "wiki/index.typ")
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
