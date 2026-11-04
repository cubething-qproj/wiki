#import "../../template.typ": *
#show: article.with(
  title: [Dependency parsing],
  summary: [Recovering a sentence's grammatical structure with a small, fast, deterministic model.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Understanding text",
  documents: ("debate-pipeline",),
)

A *dependency parser* labels each word in a sentence with its grammatical
role and the word it depends on. In "living is shared with plants", _living_
is the subject, _is shared_ is the root, and _with plants_ modifies it. Simple
rules over this structure can then find a clause's subject and predicate, or
where one clause ends and the next begins.

Parsers such as spaCy's are small (tens of megabytes), fast on a CPU, and
deterministic: the same input always gives the same output. That makes them a
good baseline. Any more expensive model should have to beat it.

= In Quell <parsing-quell>

The proposed argument-analysis pipeline would use parsing, together with
discourse markers such as "because", as the rule baseline in two places. It
would find where the argumentative units in a text begin and end, and propose
each statement's subject and predicate. These are the terms that the
#l("explainer-pta")[PTA] compares to determine an argument's form. Most
parsers are trained on news and web text, so they may struggle with the long
sentences and older syntax of philosophical writing. That is something the
gold maps would measure.

= External links <parsing-external>

- #link("https://spacy.io/")[spaCy] — the parser library.
- #link("https://universaldependencies.org/")[Universal Dependencies] — the
  cross-language annotation scheme most parsers follow.
