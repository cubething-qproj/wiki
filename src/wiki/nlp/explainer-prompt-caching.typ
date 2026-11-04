#import "../../template.typ": *
#show: article.with(
  title: [Prompt caching],
  summary: [Reusing a language model's work on a shared prompt prefix across many calls.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Generating text",
  documents: ("debate-spike",),
)

Before a language model writes anything, it processes the whole prompt. The
intermediate results of that processing are kept in a *key–value (KV) cache*,
so that each new token does not have to recompute them. If many calls begin
with the same text, such as instructions and fixed examples, that shared
beginning can be processed once and its cache reused. The llama.cpp server
does this automatically for a shared prefix.

The saving applies only to a prefix, an identical _beginning_. A prompt is
therefore ordered with the fixed material first and anything that varies
afterwards. Retrieved examples and the new input come last.

= In Quell <caching-quell>

Prompt processing is a large part of a small model's running time on a CPU.
Caching the fixed part of the prompt is one of the cost reductions the
argument-analysis spike would try once it works at all.

= See also <caching-see-also>

- #l("explainer-in-context-learning") — why prompts contain examples.
- #l("explainer-quantization") — llama.cpp, which provides the cache.
