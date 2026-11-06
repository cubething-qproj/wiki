#import "../../template.typ": *
#show: wiki-page.with(
  title: [Gold maps and measurement],
  status: "draft",
  summary: [Reviewed maps, and how arms are scored against them.],
)

The gold maps are reviewed xAIF files in `misc/labs/xAIF/examples`. Each one
is both game content and a test case for every #l("debate-arms")[arm].

== What exists

- *Reviewed:* `aquinas-llm.json`, `engels-alt.json`.
- *Drafted, awaiting Ada's critique:* `aristotle-function.json`.
- *Every way into an RA:* `ra-inputs.json`, also the conformance suite for any
  re-implementation of the rules.
- *Conventions:* `judgement-calls.md`, the seed of a labelling guide.
- *Corpus:* 31 excerpts from 29 writers in `misc/labs/nlp/data/pta-corpus`.
  Never committed.

== How a map gets made

```mermaid
flowchart LR
  P["draft: by hand,<br/>an agent, or an arm"] --> E["review in<br/>the xAIF editor"]
  E -->|accepted / fixed| G[("gold maps")]
  E -->|new kind of decision| J["judgement-calls.md"]
  J --> P
  G -->|"few-shot examples,<br/>thresholds"| P
```

Cloud models and agents are allowed here, for drafting and labelling. The
game never depends on them.#outdated[Model-drafted maps were dropped (2026-11-06); maps are authored by hand.]

== How arms are scored

#outdated[Scoring automated arms against gold was dropped (2026-11-06) along with the arms.]

- *#l("explainer-stage-wise-evaluation")[Stage-wise].* Feed the gold
  answers to every step before the one under test.
- *Split by writer.* No writer's text helps label their own.
- *Exemplars first.* Look at the worst cases before computing statistics.
- *#l("explainer-calibration")[Calibration].* When an arm says 80%, is it
  right 80% of the time? The editor will show confidences.
- *A human ceiling.* A second annotator on a sample shows how much people
  disagree.

#undecided[How many reviewed maps before scores mean anything? Draft 1 guessed
  10 of 31.]
