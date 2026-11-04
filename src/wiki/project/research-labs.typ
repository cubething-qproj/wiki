#import "../../template.typ": *
#show: article.with(
  title: [Research labs],
  summary: [The local Python and web labs where Quell's generators and language tools are prototyped and measured.],
  documents: ("quell-hex-terrain-r11-design", "quell-reading-notes-design", "debate-gold"),
)

Some of Quell's systems are hard to judge from inside the game. They include
a trail generator that must feel "lost but readable", or a model that has to
recognize what a player's note is about. Such questions are worked out in
*labs* under `misc/labs/`. These are small local repositories, built for fast
iteration and measurement. The game never depends on them. Once an approach
has been chosen, it is ported to Rust.

#contents()

= The three labs <labs-inventory>

#table(
  columns: (auto, auto, 1fr),
  table.header([Lab], [Stack], [Question it answers]),
  [hex-lab \ `misc/labs/hex`],
  [Python, uv],
  [How should terrain and trails be generated? It simulates regional
    erosion, selects board windows, lays out landmarks and trails, and renders
    comparison figures.],
  [note-lab \ `misc/labs/nlp`],
  [Python, uv; INCEpTION],
  [Which concepts is a player's highlight or note about? It defines the
    annotation data format and validates data sets. It is meant to compare
    interpreters, from authored annotations to small local models.],
  [xAIF editor \ `misc/labs/xAIF`],
  [Svelte, TypeScript],
  [What argument structure does a text have? It is a browser editor for
    argument maps in IAT/xAIF, annotated with Periodic Table of Arguments
    types.],
)

hex-lab is the most mature of the three. The current Rust generator in the
`hex_paths` development screen follows the lab's experiment 15 (`exp/15-density`),
which had a 15-experiment history behind it.#footnote[The module documentation
of `bin/quell/src/screen/dev/hex_paths/mod.rs` names the lab tag and arm it
follows.] note-lab so far has its data format, a `check` command and
"tier 0" concept coverage. No model interpreters have been measured yet. The
xAIF editor is in use: it has produced the reviewed argument maps described in
#l("argument-maps").

= Prototype, measure, then port <labs-method>

The labs share a working method:

- *One experiment, one tag.* Each experiment is a commit tagged `exp/NN-name`,
  with a write-up in `experiments/NN-name.md`. Its figures are stored under
  `.docs/designs/`. Checking out the tag reproduces the experiment.
- *Examples before statistics.* An experiment first shows a few illustrative
  examples, such as boards for chosen seeds. Large many-seed statistical runs
  are only done when needed.
- *Failures count.* Samples that violate the generator's constraints are kept
  in the results, not filtered out, so that the summaries are not flattering.
- *Port one choice.* Only the approach that has been chosen is rewritten in
  Rust. hex-lab's `check-port` command compares a Rust port with its Python
  original by distribution rather than seed by seed, because the two use
  different random number generators.

The figures in #l("terrain-generation") and #l("trail-layout") come from these
experiments. They show the Python prototype, not the game.

= Data that stays local <labs-data>

The language labs work with excerpts from real philosophy books, which must
not be published. In note-lab, everything under `data/` is ignored by Git except
a small invented fixture. The xAIF editor's example maps quote passages and are
committed only to its local repository. None of the three labs has a remote,
and this wiki, which can quote the same material, is also local-only.

Whether the game can ship such texts is a separate licensing question. See
#l("debate-system").

= See also <labs-see-also>

- #l("portal-pcg") — what hex-lab's experiments established.
- #l("reading-notes") and #l("argument-maps") — what note-lab and the xAIF
  editor are for.
- #l("repository-layout") — how the labs relate to the other repositories.

= External links <labs-external>

- #link("https://docs.astral.sh/uv/")[uv] — the Python project manager used
  by both Python labs.
- #link("https://inception-project.github.io/")[INCEpTION] — the annotation
  server note-lab uses for labelling.
