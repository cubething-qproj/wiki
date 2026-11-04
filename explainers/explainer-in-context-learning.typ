#import "../_template.typ": *
#show: wiki-page.with(
  title: [In-context learning (few-shot)],
  status: "current",
  summary: [Teach a model a task with solved examples in the prompt.],
)

Put a few solved examples in the prompt, then the new input, and the
model continues the pattern. No training needed. *Zero-shot* uses
instructions only; *few-shot* adds examples.

*Retrieved* few-shot picks, for each input, the examples most similar
to it, usually by #l("explainer-embeddings")[embedding]. Examples
cost prompt length, and on a CPU prompt processing takes time, so
fewer, better-chosen examples are cheaper.
