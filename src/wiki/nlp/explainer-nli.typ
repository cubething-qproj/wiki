#import "../../template.typ": *
#show: article.with(
  title: [Natural language inference],
  summary: [Classifying whether one text entails, contradicts or is neutral towards another, and using that for zero-shot classification.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Understanding text",
  documents: ("debate-pipeline",),
)

*Natural language inference* (NLI), also called textual entailment, is the
task of deciding how two texts relate. Given a *premise* and a *hypothesis*,
an NLI model says whether the premise *entails* the hypothesis,
*contradicts* it, or is *neutral*. "Every bodily part has a function" entails
"the eye has a function". It contradicts "the eye is useless".

= Zero-shot classification <nli-zero-shot>

NLI models can also classify text into labels they were never trained on.
Each label is written out as a hypothesis, and the model measures how strongly
the text entails it. To ask whether an argument rests on cause, for example,
the hypothesis could be "the premise describes a cause of the conclusion".
The label with the strongest entailment wins.

Small NLI models exist. DeBERTa-v3-xsmall, for instance, is about 70 MB, and
it runs well on a CPU.

= In Quell <nli-quell>

#outdated[Automated and runtime argument analysis was dropped (2026-11-06); arguments and dialogue are authored by hand.

  The proposed argument-analysis pipeline uses NLI at several steps. It would
  check whether one statement supports or opposes another, whether a reworded
  statement still means the same as the original, and which lever best fits an
  argument.
]

= See also <nli-see-also>

- #l("explainer-cross-encoders") — NLI models are a kind of cross-encoder.
- #l("explainer-pta") — the levers that zero-shot classification would choose
  between.

= External links <nli-external>

- #link("https://en.wikipedia.org/wiki/Textual_entailment")[Textual entailment]
  — background on the task.
