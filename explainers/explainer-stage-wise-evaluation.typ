#import "../_template.typ": *
#show: wiki-page.with(
  title: [Stage-wise evaluation],
  status: "current",
  summary: [Score each step on its own, with gold inputs.],
)

To find which step of a pipeline fails, feed it the _gold_ answers for
every step before the one under test. Its errors are then its own. To
score lever choice, feed it the gold canonical statements; to score
reconstruction, feed it the gold segments and relations.

For direct generation, which does every step at once, score the
output's parts separately: locutions, relations, statement fields,
levers.
