#import "../_template.typ": *
#show: wiki-page.with(
  title: [Argument mining and oAMF],
  status: "current",
  summary: [Finding arguments in text automatically.],
)

*Argument mining* is the research field that finds argumentative units
in text and classifies the relations between them (support, attack). On
edited prose, finding units works fairly well; finding relations,
especially implicit ones, much less so.

*oAMF*, ARG-tech's open Argument Mining Framework, chains mining modules
(segmenters, relation classifiers) and reads and writes xAIF, our
format. That makes it a natural candidate arm. Not yet researched: which
modules exist, how good they are on philosophy, and whether they run
locally. Source: #link("https://github.com/arg-tech").
