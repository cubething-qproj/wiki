#import "../../template.typ": *
#show: wiki-page.with(
  title: [The oracle pipeline],
  status: "draft",
  flags: ("outdated",),
  summary: [Rules plus one small model per question.],
)

#outdated[The automated text-to-map pipeline was dropped (2026-11-06); arguments are authored by hand.]

#note[Family B on the #l("debate-arms")[arms] page. Source:
  `.docs/designs/pta-atip-algorithm.typ`.]

The procedure is mostly rules. Every judgement a rule can't make is an
*oracle*: a function that answers one small question with a probability for
each answer. Each oracle has arms (a rule baseline, a small model, a larger
one), compared on gold one oracle at a time. It's reliable and easy to debug,
but each specialised model costs compute and work.

```mermaid
flowchart TD
  A["text"] --> S1["1 · segment into locutions"]
  S1 --> S2["2 · relate: TA, YA, RA/CA/MA"]
  S2 --> S3["3 · reconstruct canonical statements"]
  S3 --> S4["4 · analyse statements"]
  S4 --> S5["5 · type: form + substance (rules), lever"]
  S5 --> S6["6 · tag concepts"]
  S6 --> R["review in the xAIF editor"]
  click S1 href "#s1"
  click S2 href "#s2"
  click S3 href "#s3"
  click S4 href "#s4"
  click S5 href "#s5"
  click S6 href "#s6"
```

The order follows how a human annotator works. Each step's arms:

#table(
  columns: (auto, 1fr, 1fr),
  table.header([step], [decides], [arms]),
  [#anchor("s1")1 · segment],
  [which spans are argumentative units (L-nodes)],
  [#l("explainer-dependency-parsing")[parser] + discourse markers;
    #l("explainer-gliner2")[GLiNER2] spans; small LLM;
    #l("explainer-argument-mining")[oAMF] segmenters],

  [#anchor("s2")2 · relate],
  [which unit answers which; argue, disagree or restate; reported speech;
    unstated premises],
  [marker rules; #l("explainer-nli")[NLI] over pairs; LLM proposal
    checked by NLI],

  [#anchor("s3")3 · reconstruct],
  [each I-node's wording, which decides the form. The hardest step.],
  [O2 same term? (lemma + coreference, #l("explainer-embeddings")[embeddings], #l("explainer-cross-encoders")[cross-encoder]); O9
    rewrite proposer (generative); O10 rewrite check (NLI both ways)],

  [#anchor("s4")4 · analyse],
  [subject/predicate (O1), F/V/P (O3), s/p/u (O4), second-order + A/U (O5),
    perspective (O6)],
  [rules (modals, quantifiers, reporting verbs) first; then GLiNER2 or small
    classifiers],

  [#anchor("s5")5 · type],
  [form and substance by rule (`deriveCode`); γ's i/d (O7); the lever (O8)],
  [cue words; NLI over each candidate lever written as a sentence],

  [#anchor("s6")6 · concepts],
  [what each argument is about],
  [reading-notes lab tiers: authored ranges, embeddings, GLiNER2],
)

Two rules from the judgement-call log:

- If step 5 lands on `novel`, send the argument back to step 3. `novel` usually
  means a missed premise, a wrong statement type or a wrong form.
- "A claim about a kind is universal." "F if you can check it by looking, V if
  it applies a standard."

== Runtimes

Lab models run through #l("explainer-onnx")[ONNX Runtime], so the game
can run the same model through `ort` in Rust. Generative arms run through
llama.cpp.
