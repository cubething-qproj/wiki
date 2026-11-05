#import "../../template.typ": *
#show: article.with(
  title: [xAIF editor],
  summary: [The lab's browser editor for argument maps: what it is for and why we built it.],
  authors: ("Claude Sonnet 5.5",),
  date: "2026-11-05",
  topic: "Organization",
  documents: ("pta-atip-algorithm", "debate-gold"),
)

The xAIF editor is a lab for drawing and checking argument maps. It lets a
person take a passage of philosophy, mark who said what, reconstruct the
claims in plain canonical form, and link them into a graph that records which
claims support or attack which. Each support link is typed with the Periodic
Table of Arguments, and the editor works that type out itself.#footnote[Checked
  against `misc/labs/xAIF/README.md` and `judgement-calls.md`, 2026-11-05.]

#media(
  "/media/nlp/xAIF-editor.png",
  alt: "The xAIF editor with a passage from Bernard Suits on the left, a graph of locutions, propositions and an inference in the middle, and the inspector for the selected inference on the right.",
  caption: [The editor on a passage from Bernard Suits. Source text, graph and inspector sit side by side. The selected inference has its type derived from its statements.],
)

The NLP research it served is being dropped. The editor is kept because a
structured, checkable model of an argument may still be useful elsewhere.

= Why we built it <xaif-why>

The debate idea needed gold-standard maps: hand-reviewed graphs that a game, or
an automated analyser, could be measured against.#footnote[See
  #doc("debate-gold")[Gold maps and measurement].] The first labelling tool,
INCEpTION, is a general annotation server. It could not enforce the shape of an
IAT graph, and it could not derive an argument's type from the statements it
connects, so a labeller had to choose type codes by hand and mistakes went
unnoticed.#footnote[The limits of INCEpTION are listed in
  #doc("pta-atip-algorithm"), under "Sources".]

A purpose-built editor fixes both. It only allows connections that Inference
Anchoring Theory permits, and it derives each inference's type from its
statements, so the only judgement left to the labeller is the lever. Reviewing
a map then means reviewing the reconstruction, which is the part that needs a
human.

= What it gives us <xaif-gives>

- Format: maps are stored as xAIF, ARG-tech's JSON format for argument
  graphs, with a few additions for the type data. See #l("argument-maps") for
  the model and the workflow.
- A log of interpretive decisions (`judgement-calls.md`) that doubles as a
  draft labelling guide, so the same question gets the same answer next time.
- A conformance file, `examples/ra-inputs.json`, listing every way into an
  inference and the type it should derive. Any reimplementation of the rules
  can be tested against it.
- A working check of the PTA procedure. Explaining why an inference gets its
  type is easier with the graph in front of you. See #l("explainer-pta").

= See also <xaif-see-also>

- #l("argument-maps") — the maps made with it.
- #l("research-labs") — the other labs, and the rules for texts that cannot be
  published.
