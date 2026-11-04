#import "../../template.typ": *
#show: article.with(
  title: [Argument maps],
  summary: [The reviewed IAT/PTA graphs of each text that the debate mechanic would be built on.],
  documents: ("debate-gold", "debate-pipeline", "debate-arms", "pta-atip-algorithm", "pta-document-analysis"),
)

An *argument map* records what a text says, and how its claims support or
oppose one another, as a graph. Quell's maps combine two published frameworks.
*Inference Anchoring Theory* (IAT) structures the whole text or dialogue.
The *Periodic Table of Arguments* (PTA) gives each individual argument a type.
They are stored as xAIF JSON with a few additions, and edited in the lab's
xAIF editor. Reviewed maps are intended both as #l("debate-system")[debate]
content and as the gold standard for automated analysis.#footnote[Format and
derivation rules checked against `misc/labs/xAIF/README.md` and its tests;
the status of the maps is from #doc("debate-gold")[Gold maps and measurement].]

#contents()

= Two frameworks <maps-frameworks>

IAT keeps two layers: the *locutions*, the exact words and who said them, and
the *propositions*, what was asserted, reconstructed in a canonical form.
Speech acts such as Asserting and Arguing anchor each proposition and
inference in the words that perform it. This is what would let a player's
highlight, a span of words, be traced to the statement it expresses. See
#l("explainer-iat") for the node types and a worked diagram.

The PTA describes each inference as a *premise* supporting a *conclusion*
through a usually unstated *lever*. Its type, written as a code such as
`α FF Cau`, follows from what the two statements share (*form*), what kinds of
statement they are (*substance*), and the lever. See #l("explainer-pta").

= Derived, not chosen <maps-derived>

In Quell's maps, an inference's form and substance are *derived*. They follow
from the canonical statements it connects, never from a hand-picked label, and
only the lever is chosen. The rewording that turns a locution into its
canonical statement is recorded on the speech act between them. This makes
reconstruction, the step that needs the most judgement, an explicit and
reviewable step.

= How a map is made <maps-workflow>

In the editor, a reviewer:

+ pastes the passage and adds speakers;
+ marks *locutions* as spans of the text;
+ rewrites each proposition into canonical form, recording the
  transformations used;
+ analyses each statement: subject, predicate, fact, value or policy, and
  scope;
+ links premises to conclusions and anchors each relation in the dialogue.

The editor then derives each inference's type and warns about structures
IAT does not allow. A draft can come from hand annotation, from an agent, or
from an automated approach. A person reviews it either way. Interpretive
decisions are logged in `judgement-calls.md`, which is becoming the labelling
guide.

= Current state <maps-state>

- *Gold maps.* Two maps are reviewed, of passages from Aquinas and Engels.
  A third, of Aristotle's function argument, is drafted and awaiting review.
- *Conformance examples.* `ra-inputs.json` covers every combination of
  statements that can feed an inference, each labelled with the code it should
  derive. The editor's tests
  check the labels. Any reimplementation of the rules, such as a Rust core for
  the game, is meant to be checked against the same file.
- *Corpus.* The pilot corpus has 31 excerpts from 29 writers. It is held
  locally and never committed.
- *Automation.* No automated approach has been chosen. Candidates include a
  single model writing the whole map, a pipeline of rules plus small
  specialised models, ARG-tech's oAMF, and hybrids. They are to be scored
  stage by stage against the gold maps, split by writer so that examples from
  one writer are never used to label that writer's own texts.

#undecided[How many reviewed maps are needed before scores mean anything.
The first draft of the plan guessed 10 of the 31 excerpts.]

#undecided[Where reported speech belongs: do reported locutions sit in the
reporter's chain of transitions? This is open in the judgement-call log, and it
affects segmentation rules and export.]

#undecided[Whether INCEpTION or the xAIF editor is the annotation tool. So
far, all real annotation has been done in the editor.]

= See also <maps-see-also>

- #l("debate-system") — how the maps would be used in play.
- #l("reading-notes") — the separate question of what a player's note is about.
- #l("research-labs") — the labs that hold the editor and corpus.

= External links <maps-external>

- #link("https://github.com/arg-tech/xaif")[xAIF] — ARG-tech's JSON format
  for argument graphs.
- #link("https://www.periodic-table-of-arguments.org/argument-type-identification-procedure")[Argument Type Identification Procedure]
  — the PTA's published classification procedure.
