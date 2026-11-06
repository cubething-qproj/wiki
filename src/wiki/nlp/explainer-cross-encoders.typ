#import "../../template.typ": *
#show: article.with(
  title: [Cross-encoders],
  summary: [Models that score a pair of texts by reading them together: slower than embeddings, but usually more accurate.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Understanding text",
  documents: ("debate-pipeline",),
)

An #l("explainer-embeddings")[embedding model] encodes each text on its own,
so texts can be embedded in advance and compared cheaply. A *cross-encoder*
instead reads two texts together and outputs a single score for the pair,
for example "how well does this passage answer this question?". Because the
model sees both texts at once, it can notice interactions between them that
separate embeddings miss. It is usually the better judge of whether two
texts mean the same thing.

The cost is that nothing can be precomputed. Every pair needs its own run of
the model. The common arrangement is therefore two-stage. Embeddings quickly
pick a shortlist of candidates, and a cross-encoder re-ranks only that
shortlist.

= In Quell <cross-encoders-quell>

#outdated[Automated and runtime argument analysis was dropped (2026-11-06); arguments and dialogue are authored by hand.

  In the proposed argument-analysis pipeline, a cross-encoder is one candidate
  for deciding whether two phrasings are "the same term". That decision
  determines an argument's #l("explainer-pta")[form]. Like every other
  candidate, it would be measured against the reviewed gold maps.
]

= See also <cross-encoders-see-also>

- #l("explainer-embeddings") — the faster first stage.
- #l("explainer-nli") — a related kind of pair classifier.

= External links <cross-encoders-external>

- #link("https://www.sbert.net/")[Sentence Transformers] — includes
  cross-encoder models and documentation.
