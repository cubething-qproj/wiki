#import "../../template.typ": *
#show: article.with(
  title: [Embeddings and cosine similarity],
  summary: [Representing text as vectors so that similar meanings can be found by simple arithmetic.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Understanding text",
  documents: ("quell-reading-notes-design", "debate-spike"),
)

An *embedding model* turns a piece of text into a vector, a list of a few
hundred numbers. It is trained so that texts with similar meanings produce
vectors pointing in similar directions. "The eye has a purpose" and "every
organ has a function" end up close together. "The river is cold" ends up
somewhere else.

= Comparing texts <embeddings-cosine>

The usual measure of closeness is *cosine similarity*, the cosine of the
angle between two vectors. A value of 1 means they point the same way, and
values near 0 mean the texts are unrelated. Each text is embedded once. After
that, comparing two texts is just a dot product, so searching thousands of
candidates is cheap.

Models that embed each text separately, as here, are called *bi-encoders*. They are fast but somewhat coarse. A
#l("explainer-cross-encoders")[cross-encoder] reads both texts together and is
usually more accurate, at a higher cost.

= Small models <embeddings-small>

Sentence-embedding models such as MiniLM, BGE-small and E5-small are 20–130
MB and run comfortably on a CPU. That makes them practical inside a game that
cannot rely on a strong GPU. They can be exported to
#l("explainer-onnx")[ONNX] and run from Rust.

= In Quell <embeddings-quell>

Embeddings are planned for three jobs:

- *Interpreting notes*: comparing what a player writes with descriptions of
  each concept, to work out which concepts a note is about. This is tier 1
  of #l("reading-notes").
- *Retrieving examples*: choosing the solved examples most similar to a new
  passage, for #l("explainer-in-context-learning")[few-shot prompting].
- *Checking terms*: testing whether two phrasings in an argument mean the
  same thing.

= External links <embeddings-external>

- #link("https://www.sbert.net/")[Sentence Transformers] — a widely used
  library and model collection for sentence embeddings.
- #link("https://en.wikipedia.org/wiki/Cosine_similarity")[Cosine similarity]
  — the measure itself.
