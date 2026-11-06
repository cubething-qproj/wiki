#import "../../template.typ": *
#show: article.with(
  title: [Stage-wise evaluation],
  summary: [Scoring each step of a pipeline on its own, by giving it correct inputs from the steps before.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Measuring results",
  documents: ("debate-gold", "debate-pipeline"),
)

When a multi-step pipeline gets an answer wrong, the score at the end does not
show which step failed. An error early on spoils everything after it.
*Stage-wise evaluation* isolates each step by giving it the _gold_
(human-reviewed) answers for every earlier step. Whatever mistakes it then
makes are its own.

For argument maps, that means:

- to score segmentation, provide only the text;
- to score reconstruction, provide the correct segments and relations;
- to score lever choice, provide the correct canonical statements.

A model that produces the whole map in one go has no separate steps to feed.
Its output is scored instead by part: locutions, relations, statement fields
and levers, each compared against the gold map.

= In Quell <stage-wise-quell>

#outdated[Automated and runtime argument analysis was dropped (2026-11-06); arguments and dialogue are authored by hand.

  All candidate approaches to building #l("argument-maps")[argument maps] are
  to be scored this way against the reviewed gold maps. The evaluation is split
  by writer, so that examples from one writer are never used to label that
  writer's own texts. Individual
  bad cases are to be inspected before summary statistics are computed.
]

= See also <stage-wise-see-also>

- #l("explainer-calibration") — another measure used in the same evaluation.
