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

`misc/labs/nlp/spike/`, in TypeScript. It calls `llama-server` over HTTP and
imports the editor's rules from `misc/labs/xAIF/src/lib`. The notation is
`notation.ts`. `expand.ts` and `abstract.ts` convert it to and from xAIF; the
six gold maps round-trip exactly. `schema.ts` is the grammar, and
`retrieve.ts` picks examples by BM25 over whole gold maps.

Gold data, all reviewed, in `misc/labs/xAIF/examples/`: `aquinas-llm`,
`aristotle-function`, `engels-alt`, `searle-chinese-room`,
`suits-absurd-games` and `truth-woman`.

== Downloads

`extra/llama-cpp` (0.6.0) and Qwen3.5 4B Instruct at Q4_K_M (2.74 GB,
unsloth's GGUF, Apache 2.0), in the lab's gitignored `models/`. No embedding
model: BM25 retrieval needs none.

== First run (2026-11-05)

One hand-built call: the Suits passage, with Engels-alt and Searle as
examples, through the chat endpoint with thinking off, on 12 threads with
other applications running.

- *Time:* 3,196 prompt tokens at 99 tokens/s (32 s); 829 output tokens at
  8.1 tokens/s (102 s). About 2¼ minutes for one passage.
- *Validity:* the output matched the schema but didn't expand. It anchored
  relations on transitions without writing any `replyTo`, so `replyTo` is
  now required.
- *Exemplar:* with transitions filled in, the map lints clean. Segmentation
  was close to gold, and the flat rejection came out as gold has it (a
  second-order U statement in conflict with the view). Reported speech was
  missed, so the observers' argument, the rephrase and the undercut are
  absent. Of three RAs, one treats a contrast as an argument, one uses its
  premise as its own lever statement, and two have levers that don't fit
  the derived form and substance.

A zero-shot call, with no examples, looped inside `replyTo` until it ran out
of tokens; arrays in the schema are now bounded.

== Decision

The passage-mode runner is not being built. Generation speed is about what
this model gets on this machine, a full map is hundreds of tokens, and the
errors are of reading, not of format, which more examples are unlikely to
fix. The next experiment tests the #doc("debate-pipeline")[oracle pipeline]
instead: oAMF's argument-relation classifier (ARIR) and statement-type
classifier (PTCR), both fine-tuned RoBERTa-large, scored against the
relations and F/V/P labels in the gold maps. Both are licensed
CC BY-NC-SA 4.0, so they can be used in the lab but not in a commercial
release.
