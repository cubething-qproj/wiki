#import "../../template.typ": *
#show: wiki-page.with(
  title: [Phases],
  status: "draft",
  summary: [Two tracks, from gold maps to a playtest.],
)

#outdated[Track A's NLP steps (A1 spike, A3 more arms, A4 assisted annotation) were dropped (2026-11-06). Gold maps are hand-authored.]

Two tracks that meet at the exporter. The game track can start from hand-made
maps; it doesn't wait for any model.

```mermaid
flowchart TD
  subgraph A["Track A · content and NLP (lab)"]
    A0["A0 · gold maps"] --> A1["A1 · spike: NL → xAIF"]
    A0 --> A2["A2 · shared core:<br/>type table, conformance suite"]
    A1 --> A3["A3 · more arms,<br/>scored on gold"]
    A2 --> A3
    A3 --> A4["A4 · assisted annotation"]
  end
  subgraph G["Track G · game (Quell)"]
    G1["G1 · q_pta crate"] --> G2["G2 · exporter + assets"]
    G2 --> G3["G3 · vertical slice"]
    G3 --> G4["G4 · playtest"]
  end
  A2 --> G1
  A0 --> G2
  A3 -. "runtime parse?" .-> G3
  click A0 href "debate-gold.html"
  click A1 href "debate-spike.html"
  click A3 href "debate-arms.html"
  click G1 href "debate-game.html"
  click G3 href "debate-game.html"
```

- *A0 · Gold maps* (now): draft, critique, fix, log judgement calls.
- *A1 · Spike* (next): see #l("debate-spike")[the spike].
- *A2 · Shared core:* the PTA table as one JSON file; `ra-inputs.json` as the
  conformance suite for TS, Python and Rust.
- *A3 · More arms:* the #l("debate-pipeline")[oracle pipeline], oAMF, hybrids,
  compared on gold.
- *A4 · Assisted annotation:* arms write draft xAIF with confidences; the
  editor shows them for review.
- *G1–G4:* the core crate, exporter, a vertical slice (one text of about 20
  statements, 3–4 levers, one NPC), then a playtest: _is building one argument
  against one NPC fun?_

*Deferred:* fine-tuning beyond the spike's LoRA arm, until the materials
settle.
