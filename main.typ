// qproj design wiki: one Typst bundle, one HTML file per page.
//
// Serve with live reload: `just serve` (in this directory). That regenerates `manifest.json`
// first; rerun it after adding, removing or renaming a page.
// See `_template.typ` for how pages are written.

#import "_template.typ": *

#for p in manifest.pages {
  document(p.name + ".html", {
    current.update(p.name)
    include p.path
  })
}

#document("index.html", title: [qproj design wiki], shell([qproj design wiki], home()))
#document("status.html", title: [Status], shell([Pages by status], status-index()))
#for a in areas {
  document(a.id + ".html", title: a.title, shell(a.title, area-index(a)))
}
