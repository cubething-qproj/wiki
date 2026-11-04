#import "../../template.typ": *
#show: article.with(
  title: [In-context learning],
  summary: [Teaching a language model a task by putting solved examples in its prompt, without training.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Generating text",
  documents: ("debate-spike",),
)

*In-context learning* teaches a language model a task through its prompt
alone. The prompt holds a few solved examples followed by the new input, and
the model continues the pattern. No training is involved, and the model's
weights do not change.

- *Zero-shot* prompting gives only instructions.
- *Few-shot* prompting adds a handful of worked examples.
- *Retrieved* few-shot prompting chooses, for each new input, the examples
  most similar to it, usually by #l("explainer-embeddings")[embedding
    similarity].

Examples are not free. Every example lengthens the prompt, and a model has to
process the whole prompt before it writes anything. On a CPU, that is a
noticeable share of the running time. Fewer, better-chosen examples are
cheaper. Placing fixed material first lets it be reused through
#l("explainer-prompt-caching")[prompt caching].

= In Quell <icl-quell>

The planned spike retrieves similar passages from the reviewed gold maps and
uses them as examples. It tests whether a small local model can write valid
#l("argument-maps")[argument maps] this way. If enough gold data accumulates,
#l("explainer-lora")[fine-tuning] could make the examples unnecessary.

= References <icl-references>

- Brown, T. B., et al. (2020). Language models are few-shot learners.
  #link("https://arxiv.org/abs/2005.14165")[arXiv:2005.14165].
