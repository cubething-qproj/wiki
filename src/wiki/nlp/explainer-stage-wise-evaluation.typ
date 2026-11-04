#import "../../template.typ": *
#show: article.with(
  title: [Stage-wise evaluation],
  summary: [Scoring each step of a pipeline on its own, by giving it correct inputs from the steps before.],
  documents: ("debate-gold", "debate-pipeline"),
)

When a multi-step pipeline gets an answer wrong, the score at the end does not
show which step failed. An error early on spoils everything after it.
*Stage-wise evaluation* isolates each step by giving it the _gold_
(human-reviewed) answers for every earlier step. Whatever mistakes it then
makes are its own.

For argument maps, that means:

- to score how levers are chosen, provide the correct canonical statements;
- to score reconstruction, provide the correct segments and relations;
- to score segmentation, provide only the text.

A model that produces the whole map in one go has no separate steps to feed.
Its output is scored instead by part: locutions, relations, statement fields
and levers, each compared against the gold map.

= In Quell <stage-wise-quell>

All candidate approaches to building #l("argument-maps")[argument maps] are
to be scored this way against the reviewed gold maps. The evaluation is split
by writer, so that no writer's own text helps label their work. Individual
bad cases are to be inspected before summary statistics are computed.

#wip("debate-gold")

= See also <stage-wise-see-also>

- #l("explainer-calibration") — another measure used in the same evaluation.
