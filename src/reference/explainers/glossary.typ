#import "../../template.typ": *
#show: wiki-page.with(
  title: [Glossary],
  status: "current",
  summary: [Short definitions of terms used across the wiki.],
)

#table(
  columns: (auto, 1fr),
  [*arm*], [one way to answer a question: a rule, or a model with a setup],
  [*oracle*], [a judgement the rules can't make, answered with probabilities],
  [*gold*], [human-reviewed data that arms are scored against],
  [*canonical statement*], [an I-node reworded so shared terms are literally
    shared],
  [*connector*], [one argument (an RA): premise, conclusion, optional lever
    statement],
)
