#import "../_template.typ": *
#show: wiki-page.with(
  title: [NLI: natural language inference],
  status: "current",
  summary: [Does text A entail, contradict, or neither, text B?],
)

An NLI model reads a *premise* and a *hypothesis* and says whether the
premise *entails* the hypothesis, *contradicts* it, or neither.
"Every bodily part has a function" entails "The eye has a function".

NLI models are small (DeBERTa-v3 xsmall is about 70 MB) and run on a
CPU. They also do *zero-shot classification*: to ask "is this lever
CAUSE?", write the lever out as a hypothesis and see how strongly the
argument entails it. Used in the #l("debate-pipeline")[pipeline] for
relations, rewrite checks, γ's i/d and the lever.
