#import "../../template.typ": *
#show: wiki-page.with(
  title: [Dependency parsing],
  status: "current",
  summary: [Grammatical structure from a small, fast, deterministic model.],
)

A parser (spaCy here) labels each word with its grammatical role and the
word it depends on: "*living* (subject) *is shared* (root) *with
plants* (modifier)". Rules can then find a clause's subject and
predicate, or where a clause starts.

It's small (tens of MB), fast on a CPU and deterministic, so it's the
default rule baseline. It was trained on news and web text; expect it
to struggle with old philosophical syntax.
