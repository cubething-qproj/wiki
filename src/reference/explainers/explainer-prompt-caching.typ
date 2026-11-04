#import "../../template.typ": *
#show: wiki-page.with(
  title: [KV / prompt caching],
  status: "current",
  summary: [Reuse the work done on a prompt's fixed prefix.],
)

Before generating, a model processes the whole prompt, and keeps the
result in a *KV cache*. If many calls share the same beginning (rules,
fixed examples), that part can be processed once and reused. llama.cpp
does this for a shared prefix. It only helps if the shared part comes
first, so retrieved examples go after the fixed ones.
