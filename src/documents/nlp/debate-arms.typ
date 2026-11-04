#import "../../template.typ": *
#show: wiki-page.with(
  title: [Arms and decisions],
  status: "draft",
  summary: [Every way from text to map, and the gates between them.],
)

An *arm* is one way to answer a question: a rule, or a model with a given
setup. We try several arms, score each against the #l("debate-gold")[gold maps],
and keep what wins. Nothing here is chosen yet.

== The families

```mermaid
flowchart LR
  T["passage or<br/>player line"] --> D["A · direct generation<br/>one model writes the map"]
  T --> O["B · oracle pipeline<br/>rules + one small model per question"]
  T --> M["C · oAMF<br/>ARG-tech's mining framework"]
  T --> H["D · hybrids"]
  click D href "#direct"
  click O href "debate-pipeline.html"
  click M href "explainer-argument-mining.html"
  click H href "#hybrids"
```

- *A, direct generation:* light on labour, heavy on one model.
  The #l("debate-spike")[spike] is its first test.
- *B, the oracle pipeline:* from `pta-atip-algorithm.typ`. More reliable and
  easier to debug, but needs compute and work for each specialised model.
  Details: #l("debate-pipeline")[the pipeline].
- *C, oAMF:* already outputs xAIF. Needs research before it becomes a real arm.
- *D, hybrids:* mix A and B, step by step.

== Every arm meets the same gates

```mermaid
flowchart TD
  gA["an arm's output"] --> gV{"parses and lints?"}
  gV -->|no| gX["fix the arm<br/>or drop it"]
  gV -->|yes| gB{"beats the rule<br/>baseline on gold?"}
  gB -->|no| gX
  gB -->|yes| gL{"fits the latency<br/>budget on target CPU?"}
  gL -->|yes| gR["runtime candidate"]
  gL -->|no| gC{"can cost be cut?<br/>caching, fewer examples,<br/>LoRA, GPU layers"}
  gC -->|yes| gL
  gC -->|no| gAU["authoring only"]
  click gB href "debate-gold.html"
  click gC href "#direct"
  click gR href "debate-game.html"
```

"Beats the baseline" is judged #l("explainer-stage-wise-evaluation")[stage by stage], exemplars first. The latency budget isn't set yet: see
#l("debate-open")[open questions].

#anchor("direct")
== A · Direct generation

```mermaid
flowchart TD
  D["direct generation"] --> OUT{"output format"}
  OUT --> OX["raw xAIF"]
  OUT --> ON["compact notation<br/>+ deterministic expander"]
  ON --> SZ{"model size"}
  OX --> SZ
  SZ --> S1["0.5–1B"]
  SZ --> S2["1.5–3B (spike)"]
  SZ --> S3["7–8B"]
  SZ --> S4["cloud (authoring only)"]
  S2 --> PR{"prompting"}
  PR --> P0["zero-shot"]
  PR --> P1["fixed few-shot"]
  PR --> P2["retrieved few-shot (spike)"]
  P2 --> CD{"constrained<br/>decoding?"}
  CD --> C0["free text, then parse"]
  CD --> C1["JSON schema / GBNF (spike)"]
  C1 --> LA["later: LoRA, prompt caching,<br/>GPU layer offload"]
  click ON href "debate-spike.html"
  click S2 href "explainer-quantization.html"
  click P2 href "explainer-in-context-learning.html"
  click C1 href "explainer-constrained-decoding.html"
  click LA href "explainer-lora.html"
```

Choices marked "spike" are the #l("debate-spike")[spike's] starting point. Each
other leaf is a later comparison, run only if the spike works at all.

#anchor("hybrids")
== D · Hybrids

Some likely mixes, none designed yet:

- *Generate, then check.* A writes the map; B's oracles check it. For example,
  #l("explainer-nli")[NLI] checks each relation, and the editor's rules
  derive form and substance.
- *Pipeline, with one generative step.* B does everything except
  reconstruction, the hardest step, where a generative model proposes
  rewordings.
- *Generate the skeleton, classify the details.* A segments and relates; B's
  small classifiers fill in each statement's fields.

Pick hybrids from where A and B each fail on gold, not in advance.
