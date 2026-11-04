#import "../../template.typ": *
#show: article.with(
  title: [GLiNER and GLiNER2],
  summary: [Small extraction models that take their labels at run time, with no retraining.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Understanding text",
  documents: ("quell-reading-notes-design",),
)

*GLiNER* is a family of small encoder models for extracting information from
text. Most extraction models are trained on a fixed set of labels. A GLiNER
model is instead given its labels each time it is called: "find spans of type
_claim_ and _reason_", or "classify this sentence as _fact_, _value_ or
_policy_". New labels need no training. The models are small enough to run on
a CPU. GLiNER2 extends the approach to classification and structured
extraction within a single model.

= In Quell <gliner-quell>

GLiNER-family models are tier 2 of #l("reading-notes"). Given a concept
schema, they would extract from a note the concepts mentioned, the player's
stance towards them, and any structured details. They are also a candidate
for labelling statement types in argument analysis, so a single integration
could serve both labs.

= External links <gliner-external>

- #link("https://github.com/urchade/GLiNER")[GLiNER] — the original model and
  library.
