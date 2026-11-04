# Quell wiki and document library

Two reading collections share Typst, git, Vite and the source editor:

- `/wiki/`: maintained explanations about Quell and its development.
- `/documents/`: proposals, reports and historical records, with their own search.
- `/editor/?page=<id>`: the existing Typst/Vim editor, previewing the correct collection.

`/` opens the wiki. Legacy document URLs redirect to their new document paths.
This remains a local-only site: do not publish papers or book extracts.

## Run and verify

From this directory, `just serve` starts the local server (default port 3040).
From the org root:

```sh
just --justfile .docs/wiki/justfile build
just --justfile .docs/wiki/justfile test
```

Build before running the tests. The tests cover source discovery and rendered
links, collection boundaries, redirects, contents and document ordering. Use the
already running dev server for browser checks; two servers must not build into
the same `out/` and `.out-next/` directories concurrently.

## Authoring

Articles live in `articles/<area>/<id>.typ`. Start with:

```typst
#import "../../_template.typ": *
#show: article.with(
  title: [A topic],
  summary: [A one-line description.],
  documents: ("supporting-record-id",),
)

A short explanation of the topic's relevance to Quell.

#contents()

= A useful section <topic-section>

#undecided[A question that is genuinely unresolved.]
```

`contents()` generates an outline of this article only. Place it after the lead;
it becomes a left rail on wide screens and a collapsible inline block otherwise.
Use distinctive explicit heading labels for stable section links across the bundle.

Use `l("article-id")` for topic links and `doc("record-id")` for explicit document
citations; both support `#section` fragments and an optional content label.
`doc` rejects article IDs. Related documents are explicitly selected in the page
header, then listed newest-edited first with type and lifecycle status. This list
does not import their bodies into article search.

Portals live in `portals/<area>.typ`, use `article`, and have the editor ID
`portal-<area>`. Author an introduction and reading route; `article-list("area")`
generates their topic inventory. Portals are not included in topic search.

Existing `<area>/*.typ` pages remain documents using `wiki-page`. They can set
`document-type: "design"`, `"report"`, `"reference"`, etc., independently of their
`status`. Existing explainer records default to reference; other records default
to design. This does not automatically import plans, issues or handoffs.

`callout(kind: "undecided", icon: "🤔")[Text.]` provides the common emoji/header/body
structure. `undecided`, `explain`, `decide`, and the compatibility `open` helper use
that same presentation. Keep article explanations distinct from task lists and
proposal proceedings.

## Build behavior

`scripts/manifest.py` supplies stable editor IDs, collection-qualified URLs and
actual edit timestamps. Uncommitted files use their modification time; clean
files use their last commit time. A build does not make a record newer.

`main.typ` emits both collections and legacy redirects. Separate Pagefind runs
index only each collection's authored pages. Vite builds both collections and
indexes in `.out-next/` before replacing the last good output, and cleans up
removed pages. An editor save still refuses to overwrite externally changed files.

Typst's HTML exporter puts endnotes outside the page shell. A small client hook
moves them into the reading column before related documents, preserving their
native reference/backlink IDs. Without JavaScript they remain readable below the
article. Mermaid diagrams still load from the existing external CDN; a blocked
CDN leaves scrollable source but does not prevent reading or search.

The PCG portal, Terrain generation, and Trail layout and regeneration are the
initial editorial pilot. The converted PCG source records and original Markdown
files are retained pending a separate triage decision.
