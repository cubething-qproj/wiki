---
name: wiki-writing
description: Write, revise and organize articles and portals in qproj's Typst wiki (.docs/wiki/src/wiki) — what belongs in an article, design-intent framing, article and portal anatomy, metadata (authors, date, topic, flags), choosing between the WIP/undecided/citation-needed/outdated/gotcha markers, verifying claims, citing code and records, and prose rules. Use when asked to write or edit a wiki article, portal or glossary entry, turn notes or a design into an article, or flag articles for maintenance. For templates, CSS, search or build tooling, use wiki-code instead.
---

# Writing for the wiki

The wiki lives in `.docs/wiki/`, its own Git repository inside the qproj
checkout. `CONTRIBUTING.md` there is the reference for the authoring helpers
and fields. This skill is about *what* to write and how to decide. Where the
two disagree about mechanics, `CONTRIBUTING.md` and `src/template.typ` win;
where they disagree about editorial direction, this skill wins.

## What the wiki is

The wiki explains the ideas behind Quell and its tools: how we *want* things
to be. It is not a description of the current code, a project log, or an API
reference.

- **Describe intent.** Explain what a system is for, how it is meant to work,
  and why. Write that as the main text, in the present tense.
- **Link the implementation.** Point to code paths, crate docs and records in
  footnotes or links. Do not narrate the code.
- **Mark the gap.** Where the implementation falls short of the intent, add
  `#wip(...)` citing the records that describe it. Do not hedge the prose
  ("would", "is planned to") around it.
- **Audience:** a general reader with a passing interest in the project, and
  Ada, who works on it part-time and uses the wiki to remember things. Explain
  jargon on first use or link to the article that does.
- **Never describe the wiki itself** ("this article explains", "this portal
  covers", "the wiki is not an API reference"). Readers already know what a
  wiki is.

Articles have mixed authorship and may be wrong. Treat existing article text
as a claim to check, not as a source.

## Before writing

1. Read `CONTRIBUTING.md` in `.docs/wiki/`.
2. Read at least one **human-authored** article and take its tone, sentence
   length and structure as your model. The authorship table on the generated
   maintenance page (`/wiki/maintenance.html`, or the `authors:` fields in
   `src/wiki/`) shows which those are. If no article has a human author yet,
   follow the prose rules below.
3. Read the area's portal (`src/wiki/<area>/index.typ`) and its topics.
4. Search existing articles (titles, summaries, `topic:`) for overlap. Extend or
   link to an existing article rather than writing a second explanation.
5. Gather sources: the code, the records in `src/documents/`, the labs, and
   the design and plan files in `.docs/`.

## Where things go

| Content | Home |
| --- | --- |
| What a system is, how it should work, why | wiki article |
| A proposal, plan, experiment report or decision as it was made | record in `src/documents/<area>/` (only if worth keeping; don't bulk-import) |
| API usage, function contracts | the crate's Rust docs; link to them |
| Working plans, issues, handoffs | `.docs/` outside the wiki |
| A term used in several articles | a glossary entry (`src/wiki/project/glossary.typ`) |

Explain each thing in one place. Other articles summarize it in a sentence and
link to it.

## Article anatomy

```typst
#import "../../template.typ": *
#show: article.with(
  title: [Spring-arm camera],
  summary: [One line saying what the subject is.],
  authors: ("Ada", "Claude Opus 5.5"),
  date: "2026-11-04",
  topic: "Player",
  documents: ("quell-world-generation-design",),
)

A lead of one or two short paragraphs: what this is and why it matters.

#contents()

= A section with a distinctive label <camera-collision>
```

- **Lead:** answers "what is this, and why does it matter?" No history and no
  meta-commentary.
- **`#contents()`:** after the lead, only when there are three or more
  sections.
- **Sections:** organized around ideas, not around the chronology of
  proposals. A section called "In Quell" is the usual place to relate a
  general concept, such as an NLP technique, to the game.
- **Closing sections**, all optional: "See also" (only neighbours that add
  something), "References" (sources for specific claims), and "External links"
  (further reading).
- **Heading labels** must be unique across the whole bundle; prefix them with
  the article's subject (`<camera-collision>`, not `<collision>`).
- **Related records:** list record IDs in `documents:`. The footer orders them
  automatically.

## Portals

A portal (`src/wiki/<area>/index.typ`) orients a reader in one area:

1. a lead of a few sentences;
2. a short prose reading route naming where to start;
3. `= Topics` with `#article-list("area", topics: (...))`, which sets the topic
   order (the home page and topic pages follow it);
4. `= Records`, pointing to the area's document library;
5. `= See also`.

Do not repeat the generated article list as a hand-written one.

**Topics** group an area's articles by subject. When an area already uses
topics, every new article needs a `topic:`. Reuse an existing topic where it
fits. Create a new one when it would hold at least two articles or clearly
will, and add it to the portal's `topics:` order. An area with only a few
articles may have no topics at all.

## Metadata

- **`authors`** is a list. When you write or substantially revise an article,
  add yourself by model name (for example `"Claude Opus 5.5"`). Keep existing
  authors and their order, and never remove a human author. Trivial fixes
  (typos, a broken link) don't change `authors`.
- **`date`** is the date of the last substantial edit (`YYYY-MM-DD`). Update it
  whenever you add yourself or substantially revise the text.
- **`topic`**: see Portals.
- **`flags`** add page banners: `"stub"`, `"citation-needed"` and
  `"outdated"`. Remove a flag only once its problem is fixed.

## Which marker to use

| Situation | Use |
| --- | --- |
| Designed but not built, or built only partly | `#wip("record-id")`, with optional `[Detail.]`. Don't repeat "not implemented" in prose. |
| A genuinely open question that the records also leave open | `#undecided[...]`. Each question lives in one article; others link to it. |
| A claim you couldn't verify | `claim.#cn` |
| The whole article needs fact-checking | `flags: ("citation-needed",)` |
| A passage that no longer matches the plans or code | `#outdated[...]`; for the whole article, the `"outdated"` flag |
| Too short for its subject | `flags: ("stub",)` |
| A trap that is easy to fall into | `#gotcha[...]` |
| A settled decision and its reasons | a footnote citing the record where it was made. No callout. |

Don't invent open questions. If you can't find a question in the records or
the code, it isn't `undecided`. Use markers sparingly. One WIP callout near the
top usually beats one per section.

## Verifying and citing

- Check every factual claim about Quell against the code, a record, or the
  labs. Cite the source in a footnote: a code path
  (`bin/quell/src/service/player/movement.rs`), `#doc("record-id")`, or a lab
  file. A footnote saying what was checked, and when, helps Ada later.
- If you can't verify a claim, mark it with `#cn` instead of guessing or
  softening it.
- Records describe proposals at a point in time. A "current" design is not
  proof of implementation, and a newer draft can supersede an older one; check
  dates and status.
- Use `#l("article-id")` for articles and `#doc("record-id")` for records. Both
  accept `#section` fragments. External sources go under References (when
  they support a claim) or External links (further reading).
- For general background, link out (Wikipedia, papers, official docs). Don't
  reproduce it.

## Prose rules

These come from review feedback; a fuller style guide may follow.

- Plain, direct sentences. Prefer prose to bullet lists for explanation; use
  lists for genuinely list-like material.
- Use terms consistently across articles. Current choices: "character" (not
  "NPC") for the people players debate; "tracking camera", with "spring arm"
  for the mechanism; "record" for anything in the document library.
- Don't make a point more than once. If a callout says it, the surrounding
  prose doesn't.
- Keep repetition across articles down: summarize and link.
- Introduce acronyms in full once per article.
- Give figures meaningful alt text and captions. Label prototype and
  experiment images as such; they are not game screenshots.

## Content that must stay out

Assume anything in the wiki may be published. Never include book excerpts,
text from papers, or other material that can't be published. Quote at most a
phrase, and refer to the source.

## Moving, renaming and deleting

Article IDs (filename stems) and URLs are stable. Don't rename an article
casually. A move between collections needs a redirect in `src/main.typ`.
Before deleting anything, find what links to it ("What links here" on the
page, or `grep -rn '"id"' src`).

## Finishing

1. Run `just --justfile .docs/wiki/justfile check` from the org root. If a dev
   server is already running (`just serve`), let it rebuild; otherwise run
   `just --justfile .docs/wiki/justfile build`. Never run two builders.
2. Run `just --justfile .docs/wiki/justfile test`.
3. Read the rendered page in `out/wiki/` or on the dev server (port 3040):
   lead, byline, callouts, links.
4. Commit in `.docs/wiki`, not the org repository, and only when asked.
