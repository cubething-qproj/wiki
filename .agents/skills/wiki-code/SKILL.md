---
name: wiki-code
description: Maintain the implementation of qproj's Typst wiki and design-document site in .docs/wiki, including templates, generated topic pages, CSS, search, Vite, the source editor, and build/test tooling. Use for code, rendering, navigation, or frontend bugs; prose-only article writing is outside this skill's scope.
---

# Wiki code maintenance

The wiki lives in `.docs/wiki/`, a separate Git repository inside the qproj
checkout. Paths below are relative to that repository unless stated otherwise.
Read its [contributor guide](../../../CONTRIBUTING.md) for the current authoring
interface. Inspect both repositories' status before editing or committing;
commit wiki code in `.docs/wiki`, not in the org repository. Preserve unrelated
working changes. Netlify hosts the static export; the editor and source API
remain local.

## Find the owner

| Concern | Source |
| --- | --- |
| Bundle entry, generated routes, legacy redirects | `src/main.typ` |
| Page shells, navigation, metadata, links, outlines, callouts, galleries | `src/template.typ` |
| Wiki home content and portal cards | `src/wiki/index.typ` |
| Authored area portal | `src/wiki/<area>/index.typ` |
| Generated topic-page layout and title sorting | `src/topic.typ` |
| Source discovery, editor IDs, URLs, edit timestamps | `scripts/manifest.py` |
| Shared CLI/dev build | `scripts/build.mts` |
| Netlify build bootstrap and publish configuration | `netlify.sh`, `netlify.toml` |
| Dev routing, rebuilds, source API, LSP bridge | `vite.config.mts` |
| Source editor | `web/editor/`, `web/styles/editor.css` |
| Reading styles, palette, fonts | `web/styles/{main,wiki,palette,fonts}.css` |
| Theme, search results, galleries/endnotes, diagrams | `web/scripts/{theme,search,main,mermaid}.js` |
| Served images and fonts | `static/` |
| Discovery and rendered-page checks | `tests/test_collections.py` |

Do not edit `manifest.json`, `out/`, or `.out-next/`: they are generated.

## Collection and metadata invariants

- `/wiki/` contains maintained articles and authored portals. `/documents/`
  contains design records and reference material. Each has its own Pagefind
  index and search page. `/` opens the wiki.
- Discovery scans `src/wiki/*/*.typ`, `src/documents/*/*.typ`, and
  `src/reference/*/*.typ`. Top-level `src/wiki/index.typ` is included explicitly.
  A wiki area index has editor ID `portal-<area>` and URL `/wiki/<area>.html`;
  articles and records use their filename stem as the globally unique editor ID.
  Preserve IDs and redirect behavior when changing discovery or routes.
- `article` delegates to `wiki-page`; records use `wiki-page` directly.
  `main.typ` sets `current` before including authored pages. Metadata labels
  `<wiki-page>`, `<wikilink>`, `<topic-order>`, and `<maintenance>` drive generated
  views. Keep generated category pages out of authored-page metadata.
- Queries span the entire bundle. Per-article outline boundary markers and
  counter resets prevent cross-page leakage. A successful standalone page
  compile does not verify bundle-wide behavior.
- `l()` validates authored/generated IDs and records backlinks. `doc()` also
  requires a document target. Topic pages use `topic-url(area, topic)` with
  ordinary links; their URLs are not authored IDs accepted by `l()`.

## Topics and rendering

`topic-groups` groups article metadata by area and `topic:`. Portal
`article-list(..., topics: ...)` calls record display order in `<topic-order>`;
the home page reads it. Unlisted topics follow alphabetically. An area without
topics has an **Articles** group; unassigned articles in a mixed area use
**Other**. Do not maintain a second category membership list.

`topic-list` renders the shared compact `<dl>`: small text, linked topic names,
inline article links separated by dots, and no descriptions. The home page
retains portal cards; narrow screens stack them.

`main.typ` generates `/wiki/topic-<area>-<slug>.html` from these groups and rejects
URL collisions. `src/topic.typ` renders the parent-portal link, count, and
alphabetized article list **with descriptions**. Topic pages and other indexes
are excluded from search; indexed articles and records carry
`data-pagefind-body`. The article heading explicitly supplies
`data-pagefind-meta="title"`, so search doesn't use the site-brand heading.

Prefer plain semantic HTML and small CSS changes. The blog at
`~/repos/ada-x64/blog` is the visual reference. `main.css` originated there but
has local edits; do not blindly overwrite it. Put new wiki-specific overrides
in `wiki.css`. Site titles are `qproj wiki` and `qproj design docs`.

Theme initialization and the `.toggle-lights` link handler come from the blog;
the control is a link, not a button. `data-madoromi` selects Natsu palettes;
system-dark also receives the `.dark` class. Use palette tokens rather than
inventing a parallel color system. The page uses kami; dark panels use nijimi1
and summaries nijimi2 to remain distinct. Check explicit dark, system dark,
and light modes when changing surfaces.

## Search and dev-server behavior

The topbar contains a native GET form. It navigates to the current collection's
`search.html?q=…`. `web/scripts/search.js` calls the local Pagefind JS API and
renders ordinary result headings, links, and text excerpts, ten per batch.
There is no Pagefind/Svelte UI or results overlay.

Load `search.js` as `type="module"`. Its dynamic import causes Vite to inject a
top-level import; a classic script tag produces a browser syntax error even
when a static-server test passes. Verify JS routing changes through Vite.
The Vite middleware serves generated Pagefind files without transforming them.

Vite serves the editor separately from the exported reading pages. `/api/src`
uses manifest IDs and optimistic mtime checks (409 on conflicts); `/api/build`
reports build errors; `/lsp` bridges to Tinymist. Keep those contracts intact.
`main.js` relocates Typst endnotes before related documents/backlinks;
`mermaid.js` loads diagrams independently so a CDN failure doesn't block reading.

## Build and verification

Run from the **org root**, using the wiki justfile:

```sh
just --justfile .docs/wiki/justfile check
just --justfile .docs/wiki/justfile build
just --justfile .docs/wiki/justfile test
```

`check` runs Biome formatting/lint checks and Typstyle. Format touched files
rather than rewriting unrelated sources. The pre-commit hook runs `just check`.

The build discovers sources, exports a Typst bundle with
`TYPST_FEATURES=bundle,html`, copies assets, and builds both search indexes in
`.out-next/` before replacing `out/`. Do not run two builders against the same
directories. `just serve` already rebuilds on source changes; reuse a running
server and let its build finish before testing, or use the CLI when no dev
builder is running. Build/test artifacts belong inside the checkout, never
`/tmp`. If just cannot write runtime temporary files in the sandbox, set
`JUST_TEMPDIR` to an existing scratch directory inside the checkout.

Rendered Python tests require a completed build. They cover links/fragments,
collection boundaries, outlines, galleries, document ordering, and topic
navigation/membership. Extend these for meaningful changed contracts.
Check available LSP diagnostics, but verify bundle behavior with the full build;
Tinymist may not support the bundle target used by the CLI.

For frontend changes, use a bounded browser check on the live Vite server
(default port 3040). Verify the changed behavior, desktop/phone wrapping, and
relevant themes. For search, submit the form, wait for results, check titles and
collection boundaries, and confirm topic/index pages stay out of results.
`tests/browser.mjs` / `just smoke` is currently stale: it expects the removed
Pagefind UI and `#theme-toggle` and has startup issues. Do not present it as
passing or expand a small task into repairing it without need.

Netlify runs `bash netlify.sh` and publishes `out/`. The bootstrap installs Just
and Typst; Bun/Pagefind versions are controlled by the config and lockfile.
`WIKI_HOSTED=true` passes Typst's `hosted=true` input to hide local editor links.
Check hosted output as well as ordinary dev output when changing those paths.
