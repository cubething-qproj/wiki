#import "../../template.typ": *
#show: article.with(
  title: [Argument mining],
  summary: [The research field that extracts argument structure from text automatically.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Argumentation theory",
  documents: ("debate-arms", "pta-document-analysis"),
)

*Argument mining* is the branch of natural-language processing that tries to
find arguments in text automatically. It identifies claims and reasons, and
works out which supports or attacks which. Finding the argumentative units in
carefully edited prose works reasonably well. Recovering the relations between
them is much harder, especially when, as is usual, the connection is implicit.

= In Quell <mining-quell>

Argument mining is one possible way to produce #l("argument-maps")[argument
  maps] faster than annotating them by hand. ARG-tech's #l("oamf") chains
mining modules into pipelines that read and write xAIF, the format Quell's
maps already use, so its output can be compared directly with the gold maps.

= See also <mining-see-also>

- #l("argument-maps") — the maps that mining would help produce.
- #l("oamf") — ARG-tech's framework, its modules and how they fit Quell.
- #l("explainer-stage-wise-evaluation") — how candidate approaches are to be
  scored.

= References <mining-references>

- Lawrence, J., & Reed, C. (2019). Argument mining: A survey. _Computational
  Linguistics_, 45(4), 765–818.
  #link("https://aclanthology.org/J19-4006/")[ACL Anthology].

= External links <mining-external>

- #link("https://github.com/arg-tech")[ARG-tech on GitHub] — oAMF and related tools.
