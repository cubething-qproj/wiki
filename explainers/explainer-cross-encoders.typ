#import "../_template.typ": *
#show: wiki-page.with(
  title: [Cross-encoders],
  status: "current",
  summary: [Score a pair of texts together; slower, more accurate.],
)

An embedding model (a *bi-encoder*) encodes each text alone. A
*cross-encoder* reads both texts together and scores the pair. Nothing
can be precomputed, so it's slower, but it usually judges "do these mean
the same?" better. Common setup: embeddings pick a shortlist, the
cross-encoder decides.
