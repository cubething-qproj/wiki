#import "../../template.typ": *
#show: article.with(
  title: [Reading notes],
  summary: [Working out which concepts a player's highlights and free-text notes are about, so that dialogue can respond.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-03",
  topic: "Debate",
  documents: ("quell-reading-notes-design", "debate-game"),
)

While reading in-world texts, the player highlights passages and writes notes
in their own words. Non-player characters are meant to respond when the player
has engaged with particular ideas. To do that, the game needs *concept ids*,
short stable names such as `slave_morality`, derived from those highlights and
notes.#footnote[Checked against `misc/labs/nlp/README.md` and its Git
  history.]

#wip("quell-reading-notes-design")[The work so far is in note-lab.]

#contents()

= Three tiers of interpretation <notes-tiers>

The design compares interpreters in order of increasing cost:

#table(
  columns: (auto, 1fr, auto),
  table.header([Tier], [Approach], [Output]),
  [0],
  [Authored annotations: which tagged ranges does the highlight cover?],
  [score per concept, no model],

  [1],
  [Embedding similarity between the note and each concept, using a small sentence-embedding model],
  [similarity per concept],

  [2],
  [Schema-driven extraction models of the GLiNER family],
  [concepts, stance and slots],
)

Tier 0 uses only the text's authored tags. It has a clear limit: a broad
annotation gives the same answer for any highlight inside it, and an untagged
passage gives nothing. The note's own wording has to make up the difference,
which is what tiers 1 and 2 are for. Fine-tuning is deferred until there is a
corpus large enough to justify it.

Unlike argument typing, note interpretation cannot be done in advance,
because notes are written during play. A model would therefore run on the
player's machine. In the first draft of the debate plan, this was the only
model used at runtime. The current draft adds free-text argument parsing as a
second candidate.#footnote[First draft: `.docs/designs/quell-debate-roadmap.typ`,
  "Where models still run in the game". Current draft: #doc("debate-game")[Quell
    integration]. Tier 1 would run through #l("explainer-onnx")[ONNX Runtime],
  which needs no Python.] The lab therefore plans to measure latency as well as
accuracy, under CPU-throttling profiles that imitate slower machines.

= Annotation data <notes-data>

A data set is a directory of plain texts, exactly as the player reads them.
Each text can have an annotation file, along with a list of concepts and a file
of example notes labelled with their correct concepts. Annotations follow a
subset of the W3C Web Annotation model. This lets spans overlap freely and
gives the Rust side a stable specification. Offsets are counted in Unicode code
points, so a Rust port must convert them to and from byte offsets. Optional
quotations of the annotated text are checked when a data set is loaded, so
annotations that drift after an edit fail loudly.

Annotations carry an extra `layer` field for the kind of structure being
marked, such as argument structure or cross-references. Relations between
annotations are part of the model, but are not read yet. The player's own
highlights and notes would fit the same format, so authored tags and the
player's notebook could eventually share one representation.

= Current state <notes-state>

note-lab has the data format, a `check` command that validates a data set and
reports every problem, and tier 0 coverage. Its only committed data is a small
invented fixture: the real texts are book excerpts and stay local. No tier 1
or tier 2 interpreter has been measured, and the statistical method is to be
designed once real data exists.

Annotations come from a labelling tool through a converter, not by hand. The
lab's labelling guide is written for INCEpTION, after Label Studio was also
considered. Example notes and their correct labels are still written by hand.

#undecided[Whether highlights are free or snap to authored statement spans.
  The debate plan proposes snapping. The notes lab scores arbitrary highlights.
  Both are drafts.]

= See also <notes-see-also>

- #l("debate-system") — where reading and notes fit in the player's loop.
- #l("argument-maps") — the statement-level structure of the same texts.
- #l("research-labs") — note-lab's working method.

= External links <notes-external>

- #link(
    "https://www.w3.org/TR/annotation-model/",
  )[W3C Web Annotation Data Model]
  — the annotation format the data follows.
