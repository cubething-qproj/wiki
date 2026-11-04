#import "../../template.typ": *
#show: wiki-page.with(
  title: [Top-k and calibration],
  status: "current",
  summary: [Is the right answer near the top, and can we trust the confidence?],
)

*Top-1*: the first choice is right. *Top-3*: the right answer is among
the first three, useful when a reviewer picks from a short list.

A model is *well calibrated* if its confidence matches its hit rate:
things it calls 80% likely are right about 80% of the time. Badly
calibrated models are confidently wrong, which wastes a reviewer's
attention.
