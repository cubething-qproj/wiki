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

= What a map contains <maps-iat>

IAT separates what was *said* from what was *meant*, and anchors one in the
other:

- *Locutions* (L-nodes) are the exact words and their speaker. *Transitions*
  (TA) link one locution to the next.
- *Propositions* (I-nodes) are what was asserted, rewritten in a canonical
  form. *Relations* link them: inference (RA), conflict (CA) and rephrase (MA).
- *Illocutionary connections* (YA), such as Asserting, Arguing and Disagreeing,
  connect each proposition or relation to the locution that performs it.

```mermaid
flowchart LR
  L1["L: speaker's words"] --> YA1["YA: Asserting"] --> I1["I: canonical claim"]
  L2["L: later words"] --> YA2["YA: Asserting"] --> I2["I: supporting claim"]
  L1 --> TA["TA"] --> L2
  TA --> YA3["YA: Arguing"] --> RA["RA: inference"]
  I2 --> RA --> I1
```

Keeping both layers means a player's highlight, which is a span of words, can
be traced to the canonical statement it expresses. This is what allows
highlights to "snap" to known statements.

= Typing an argument <maps-pta>

In the PTA, an argument links a *premise* to a *conclusion* through a *lever*,
the usually unstated principle that connects them. Its type has three parts:

- *form*: what the two statements share. In α the subject is shared, in β the
  predicate, and in γ neither. δ applies to arguments about a whole
  proposition, such as "q is acceptable because Z said it";
- *substance*: for α, the kinds of statement (fact, value or policy); for β,
  the scopes of the subjects; γ and δ have their own values;
- *lever*: the kind of connection, such as cause, example or analogy.

Together these give 50 types, written as codes like `α FF Cau`. The
#l("explainer-pta")[Periodic Table of Arguments] article gives more detail.

In Quell's maps, an inference's form and substance are *derived*. They follow
from the canonical statements it connects, never from a hand-picked label.
Only the lever is chosen. The rewording that turns a locution into its
canonical statement is recorded on the YA between them. This makes
reconstruction an explicit, reviewable step.

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
- *Conformance examples.* `ra-inputs.json` covers every way into an
  inference, each labelled with the code it should derive. The editor's tests
  check the labels. Any reimplementation of the rules, such as a Rust core for
  the game, is meant to be checked against the same file.
- *Corpus.* The pilot corpus has 31 excerpts from 29 writers. It is held
  locally and never committed.
- *Automation.* No automated approach has been chosen. Candidates include a
  single model writing the whole map, a pipeline of rules plus small
  specialised models, ARG-tech's oAMF, and hybrids. They are to be scored
  stage by stage against the gold maps, split by writer so that no writer's
  text helps label their own.

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
