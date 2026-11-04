#import "../../template.typ": *
#show: article.with(
  title: [Constrained decoding],
  summary: [Forcing a language model's output to follow a grammar, so that it always parses.],
  documents: ("debate-spike",),
)

A language model writes its output one *token*, a word or word fragment, at a
time. At each step it assigns a probability to every possible next token.
*Constrained decoding* masks out every token that would break a given grammar
before one is chosen. The output is then guaranteed to have the required
shape. A model asked for JSON produces valid JSON, and a field restricted to
`F`, `V` or `P` can contain nothing else.

The guarantee covers _form_, not _correctness_. The output always parses, but
it can still be wrong. Constraints can also make a model's answers worse if
they force it into an awkward format. That is one reason to give the model a
compact notation rather than a verbose one.

The llama.cpp runtime accepts constraints as a JSON Schema or as a grammar in
its *GBNF* notation.

= In Quell <decoding-quell>

The planned spike asks a small local model to write argument maps in a
compact JSON notation. A deterministic program then expands that notation into
full #l("explainer-iat")[xAIF]. Constrained decoding keeps every closed choice
valid, such as statement types, scopes and #l("explainer-pta")[lever]
keywords. Wrong choices are left for the editor's checks and human review to
catch.

= See also <decoding-see-also>

- #l("explainer-quantization") — the llama.cpp runtime and model format.
- #l("explainer-in-context-learning") — the prompting that accompanies the
  constraint.

= External links <decoding-external>

- #link("https://github.com/ggml-org/llama.cpp/blob/master/grammars/README.md")[llama.cpp grammars]
  — GBNF and JSON Schema support.
