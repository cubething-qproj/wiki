#import "../../template.typ": *
#show: article.with(
  title: [Top-k accuracy and calibration],
  summary: [Whether the right answer is near the top of a model's list, and whether its confidence can be trusted.],
  documents: ("debate-gold",),
)

Two questions matter when a model's suggestions are reviewed by a person.
Is the right answer among its first few suggestions? And when it sounds
confident, is it right?

= Top-k accuracy <calibration-top-k>

*Top-1* accuracy counts how often a model's first choice is correct. *Top-3*
counts how often the correct answer is among its first three. Top-3 is the
more useful measure when a reviewer picks from a short list: a model that is
rarely first but almost always in the top three still saves most of the work.

= Calibration <calibration-calibration>

A model is *well calibrated* when its stated confidence matches how often it
is right. Of all the answers it gives 80% confidence, about 80% should be
correct. A badly calibrated model is confidently wrong. It wastes a reviewer's
attention on mistakes it claimed were safe, and makes its confidence useless as
a guide to what needs checking.

= In Quell <calibration-quell>

The argument-map editor is meant to show a model's confidence next to each
suggestion, so a reviewer knows where to look first. That only helps if the
confidences are calibrated, so calibration is one of the measures each
automated approach is to be scored on.

= References <calibration-references>

- Guo, C., Pleiss, G., Sun, Y., & Weinberger, K. Q. (2017). On calibration of
  modern neural networks. #link("https://arxiv.org/abs/1706.04599")[arXiv:1706.04599].
