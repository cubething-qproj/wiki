#import "../../template.typ": *
#show: wiki-page.with(
  title: [Spike: natural language → xAIF],
  status: "draft",
  summary: [Can a small local model write xAIF on a CPU?],
)

#note[Proposed, not yet reviewed. Downloads need Ada's approval.]

*Question:* can a small local model turn natural language into a valid xAIF
map, on a CPU, close to real time? Slow is fine at first. It has to work at
all.

*Not the question:* how good it is compared to the #l("debate-pipeline")[oracle
pipeline]. That comes after.

== How it works

```mermaid
flowchart LR
  IN["passage, or<br/>player line + context"] --> RET["retrieve k similar<br/>gold chunks"]
  RET --> PROMPT["prompt:<br/>rules + examples + input"]
  PROMPT --> LLM["llama-server<br/>grammar-constrained"]
  LLM --> NOT["compact notation<br/>(JSON)"]
  NOT --> EXP["expander:<br/>IDs, L/YA/I/TA, offsets"]
  EXP --> CHK["deriveCode + lint<br/>+ leverOptions"]
  CHK --> X[("xAIF:<br/>opens in the editor")]
  click RET href "explainer-embeddings.html"
  click PROMPT href "explainer-in-context-learning.html"
  click LLM href "explainer-constrained-decoding.html"
```

+ *Compact notation, not raw xAIF.* The model writes only the decisions:
  - locutions, as quoted spans of the input;
  - propositions: canonical text, subject, predicate, F/V/P, s/p/u, and the
    second-order fields;
  - relations: premise → conclusion, lever statement, conflict, rephrase;
  - each YA's force and transformations;
  - the lever keyword.

  xAIF is too verbose for a small model, and every output token costs time on
  a CPU.
+ *A deterministic expander* builds the xAIF: IDs, nodes, edges, and
  code-point offsets found by searching for the quoted spans. Then the editor's
  own `deriveCode` and `lint` run (`misc/labs/xAIF/src/lib/{pta,xaif}.ts`).
  Form and substance are always derived, never predicted. The lever is checked
  against `leverOptions`.
+ *#l("explainer-constrained-decoding")[Constrained decoding]:* a JSON
  schema or GBNF grammar, so the output always parses. Closed sets (F/V/P,
  forces, lever keywords) are enums.
+ *#l("explainer-in-context-learning")[Few-shot] from gold.* Split the gold
  maps into (passage, notation) chunks. For each input, retrieve the k most
  similar by #l("explainer-embeddings")[embedding], leaving out the
  input's own writer. `ra-inputs.json` adds one synthetic example of each RA
  pattern.

Sketch of the notation (field names not final):

```json
{ "locutions": [{ "id": "l1", "speaker": "Aristotle", "span": "living is apparently shared with plants" }],
  "props": [{ "id": "p1", "from": "l1", "force": "Asserting", "text": "Living is shared with plants",
              "subject": "living", "predicate": "is shared with plants", "type": "F", "scope": "u" }],
  "relations": [{ "kind": "RA", "premise": "p1", "conclusion": "p2", "lever": "EXCLUDES" }] }
```

== Two modes

- *Passage → map:* a corpus excerpt. Scored against gold.
- *Player line + dialogue context → small map:* one or two propositions and
  their relation to what came before. This is the runtime case.

== What we measure

- *Validity:* does it parse, expand and lint clean?
- *Exemplars:* outputs side by side with gold, before any statistics.
- *Time:* prompt processing vs generation, per call.

Costs to cut later, each a separate arm: #l("explainer-prompt-caching")[cache the fixed prompt prefix], retrieve fewer examples,
#l("explainer-lora")[LoRA] so examples can be dropped, offload a few
layers to the GPU.

== Where it lives

A TypeScript script in `misc/labs/xAIF` (its own repo, no remote). It calls
`llama-server` over HTTP and imports the editor's rules directly. Gold data:
`aquinas-llm.json`, `engels-alt.json` (reviewed) and
`aristotle-function.json` (awaiting critique).

== Downloads to approve

#decide[
- *llama.cpp:* the Arch package `extra/llama-cpp`, or a build inside the repo,
  never in `/tmp`.
- *One small instruct model in GGUF:* 1.5–3B parameters,
  #l("explainer-quantization")[quantized] to about 1–2 GB. Compare the
  current small Qwen, Llama, Phi and Gemma models at download time.
- *One small embedding model* for retrieval, tens of MB. Optional: plain
  word-overlap retrieval (BM25) needs no download and may do to start.

Disk is at 87%, so models go in one gitignored directory in the lab.
]
