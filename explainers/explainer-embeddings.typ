#import "../_template.typ": *
#show: wiki-page.with(
  title: [Embeddings and cosine similarity],
  status: "current",
  summary: [Text as vectors; similar meaning, similar direction.],
)

An embedding model (MiniLM, BGE-small, e5-small: 20–130 MB) turns a
phrase into a vector of a few hundred numbers, arranged so that similar
meanings point in similar directions. *Cosine similarity* is the cosine
of the angle between two vectors: 1 is "same direction", near 0 is
"unrelated".

Each text is encoded once, and comparing two is a dot product, so it's
cheap. Used for: retrieving few-shot examples (the
#l("debate-spike")[spike]), same-term checks, and notes → concepts.
