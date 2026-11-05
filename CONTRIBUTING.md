# Quell wiki and document library

Two reading collections share Typst, git, Vite and the source editor:

- `/wiki/`: maintained explanations about Quell and its development.
- `/documents/`: supporting designs, reports and historical records, with separate search.
- `/editor/?page=<id>`: the Typst/Vim editor, previewing the correct collection.

`/` opens the wiki. Legacy document URLs redirect, preserving query strings and
section fragments. Netlify hosts the static reading pages; the editor and source
API run only on the local dev server.

## Layout

```text
src/
  main.typ                 # Bundle entry point and legacy redirects
  template.typ             # Shared page, link, callout and gallery helpers
  topic.typ                # Generated topic pages with article descriptions
  wiki/index.typ           # Wiki home page and generated topic links
  wiki/<area>/             # Topic articles; index.typ is the area's portal
  documents/<area>/        # Selected designs, reports and historical records
  reference/<area>/        # Supporting reference material (currently empty)
web/
  editor/                  # HTML and TypeScript for the source editor
  styles/                  # Reading/editor CSS and Madoromi palette
  scripts/                 # Search, notes, galleries, diagrams and theme controls
static/
  media/                   # Shared images, served at /media/
  fonts/                   # Local fonts and their OFL license
scripts/
  manifest.py              # Source catalogue, stable IDs, URLs and edit timestamps
  build.mts                # Shared CLI/dev build and asset copying
tests/                    # Catalogue/render checks and optional browser smoke check
```

The repository root holds configuration, dependency files and this README.
`manifest.json`, `out/`, `.out-next/`, and dependency/cache files are generated.
Procedural directories elsewhere in `.docs/` are not automatically imported.

## Run and verify

From this directory, `just serve` starts the local server (default port 3040).
From the org root:

```sh
just --justfile .docs/wiki/justfile build
just --justfile .docs/wiki/justfile test
```

Search forms submit to `/wiki/search.html?q=…` or `/documents/search.html?q=…`.
These pages use Pagefind’s JavaScript API to render plain HTML results, with
ten results per batch. The topbar loads no search UI framework.

Build before running the Python checks. They cover discovery, collection
boundaries, links/assets, outlines, galleries and related-document ordering.
Do not start two builders for the same `out/` and `.out-next/` directories.

`just smoke` is an optional Chromium check. It is unfinished: the last attempt
failed during browser target startup/selection, and further test work was
explicitly deferred. Do not treat it as a passing validation or an editorial
prerequisite. `WIKI_TEST_PORT` can select an already running server rather than
starting a second one.

## Authoring

Articles live in `src/wiki/<area>/<id>.typ`. Start with:

```typst
#import "../../template.typ": *
#show: article.with(
  title: [A topic],
  summary: [A one-line description.],
  documents: ("quell-hex-terrain-r11-design",),
)

A short explanation of the topic's relevance to Quell.

#contents()

= A useful section <topic-section>

#undecided[A question that is genuinely unresolved.]
```

Explain what is known, rather than reproduce a proposal's chronology. Distinguish
implementation, design intent, experimental findings and unresolved questions.
Link to outside resources instead of building a general-purpose encyclopaedia.

`contents()` generates this article's outline only. Place it after the lead; it
renders as collapsible inline contents.
Use distinctive explicit heading labels for stable links across the bundle.
Each page resets heading, footnote, equation and supported figure counters.

Use `l("article-id")` for topic links and `doc("record-id")` for explicit document
citations. Both accept `#section` fragments and optional content labels. `doc`
rejects article IDs. The `documents` list selects relevant records, automatically
ordered newest-edited first, showing document type and lifecycle status.

An area's `src/wiki/<area>/index.typ` is its authored portal. It also uses
`article`, has editor ID `portal-<area>`, and is served at `/wiki/<area>.html`.
Author the introduction and reading route; `article-list("area")` supplies its
inventory. Portals are excluded from topic search.

Home and portal pages use compact definition lists: topic names link to generated
pages such as `/wiki/topic-project-organization.html`, and article links appear
inline without descriptions. Topic pages link back to their portal and list
articles alphabetically by title, with descriptions. Membership comes from the
existing `topic:` metadata; no separate category inventory is maintained.
Areas without topics use an `Articles` category; unassigned articles in a mixed
area use `Other`. Topic pages are excluded from search.

Records in `src/documents/` and `src/reference/` use `wiki-page`. Set
`document-type` independently of `status`; reference files default to reference,
other records to design. Do not move all plans, issues or handoffs into the site.

## Callouts and visual aids

`undecided[Text.]` wraps `callout(kind: "undecided", icon: "🤔")[Text.]`.
### Article metadata

`article` also takes `authors: ("Ada",)` and `date: "YYYY-MM-DD"`, which render
as the byline under the title (e.g. _Ada and Claude Opus 5.5, 4 Nov. 2026_).
Agents list themselves by model name. `topic: "..."` groups an article on its
area's portal; a portal passes the display order with
`#article-list("area", topics: ("First", "Second"))`. `flags:` adds page
banners: `"stub"` (✒️), `"citation-needed"` (🔍) and `"outdated"` (🪦).

Inline markers: `claim.#cn` adds a superscript [citation needed];
`#outdated[...]` (🪦) marks a stale passage; `#gotcha[...]` (⚠️) warns about a
trap. Record decisions as footnotes citing their records, not callouts.
`/wiki/maintenance.html` is generated: flagged articles, inline citation-needed,
outdated, WIP and undecided markers by article, and an authorship table.

`wip("record-id", ...)` marks something designed but not built: "⚒️ WIP — This
is not yet implemented. See …", citing the given records, with optional trailing
content (`#wip("debate-game")[Extra detail.]`). Use it instead of writing
"not yet implemented" in prose.
The shared presentation is an emoji, a visible type heading, and text content.
Existing `explain`, `decide`, and compatibility `open` helpers use the same format.

Use meaningful alt text and captions for images:

```typst
#gallery(
  caption: [Historical prototype comparisons. Click an image for full resolution.],
  media("/media/pcg/experiments/11-regen/regen-seed-2.png",
    alt: "Initial, pinned and Fear regeneration on the same seed-2 terrain.",
    caption: [Seed 2.]),
  media("/media/pcg/experiments/11-regen/regen-seed-3.png",
    alt: "The same three regeneration operations on seed-3 terrain.",
    caption: [Seed 3.]),
)
```

`media` also works alone. Gallery controls enhance native horizontal scrolling;
images link to full-resolution originals. Identify prototype figures as such:
they are illustrations of experiments, not necessarily current game screenshots.
The initial figures are in `static/media/pcg/`; preserve their provenance.

`web/styles/main.css` is copied verbatim from
`~/repos/ada-x64/blog/src/public/styles/main.css`. Keep wiki-specific additions
in `web/styles/wiki.css`; font declarations live in `web/styles/fonts.css`.
The Natsu Madoromi palette and theme cycle also come from the blog. Fonts are copied locally with
`static/fonts/OFL.txt`. No blog comments, analytics or social integrations are included.

## Build behavior

`manifest.py` discovers only the three content trees. IDs and public URLs stay
stable across source moves. Uncommitted files use their modification time; clean
files use their last commit time. Rebuilding is not a knowledge-verification date.

`build.mts` compiles with the wiki repository as Typst's root, copies `static/`
and the reading frontend, and builds separate Pagefind indexes in `.out-next/`.
Only a successful build replaces the previous output. The editor is served by
Vite; saves refuse to overwrite externally changed files.

A small browser hook puts native Typst endnotes inside the reading column before
related documents, preserving reference IDs. Without JavaScript they remain
readable below the article. Mermaid still uses the existing CDN; blocking it
leaves scrollable source without blocking reading or search.

The PCG portal, Terrain generation, and Trail layout and regeneration are the
initial editorial pilot. The structural pass added portals and overview
articles for `project` (a new area in `template.typ`), `engine`, `gameplay-3d`
and `nlp`; the NLP articles describe drafts, since none of it is in the game. Original PCG Markdown files and images outside this
repository remain intact pending a separate triage decision.

## Netlify

Import `cubething-qproj/wiki` into Netlify and select `main` as the production
branch. `netlify.toml` sets the build command to `bash netlify.sh` and the
publish directory to `out` (repository root as the base directory).
Subsequent pushes trigger builds through Netlify's Git integration.

Like the blog, `netlify.sh` bootstraps Just and Typst into an ignored local tool
directory. Typst is pinned to 0.15.0 for bundle export, Bun to 1.3.9, and
Pagefind is installed from `bun.lock`. The script builds both collections and
search indexes, then runs the rendered-page tests before deployment.

`WIKI_HOSTED=true` hides local Edit links. Netlify publishes only `out/`;
Vite, `/editor/`, `/api/src`, and `/lsp` remain local development features.
Pretty URLs are disabled to preserve the exported `.html` links.
