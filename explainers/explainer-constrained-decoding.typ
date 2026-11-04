#import "../_template.typ": *
#show: wiki-page.with(
  title: [Constrained decoding],
  status: "current",
  summary: [Force a model's output to follow a grammar.],
)

A model picks one token at a time. *Constrained decoding* masks out, at
each step, every token that would break a grammar, so the output always
parses. llama.cpp takes a JSON schema or a *GBNF* grammar.

Closed sets become enums, so the model can only write `F`, `V` or `P`,
or a real lever keyword. It guarantees _form_, not _correctness_: the
output parses, but can still be wrong.
