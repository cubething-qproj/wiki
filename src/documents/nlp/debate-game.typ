#import "../../template.typ": *
#show: wiki-page.with(
  title: [Quell integration],
  status: "draft",
  summary: [How debate fits into Quell.],
)

#note[Sketch. Nothing here is built; Quell has no debate, reading or dialogue
code yet.]

== The player's loop

```mermaid
flowchart TB
  READ["read in-world texts"] --> HL["highlight + take notes"]
  HL --> BANK[("statements collected")]
  BANK --> IN{"how the player argues"}
  IN --> FT["free text"]
  IN --> TE["thinking editor"]
  FT --> DEB["debate an NPC"]
  TE --> DEB
  DEB -->|NPC answers| IN
  DEB -->|win or move on| NEXT["next area / next run"]
  NEXT -->|keep what you know| READ
  click FT href "debate-spike.html"
  click DEB href "debate-evaluation.html"
```

- *Reading.* Highlights snap to authored statement spans (the map's L-nodes),
  so a highlight is always a known statement. Notes stay free text.
- *Arguing.* Two paths, both to be tried for how they feel:
  - *Free text:* the player types; a model parses it into a small map. Needs
    a #l("debate-spike")[runtime parse] that works.
  - *Thinking editor:* the player links collected statements, premise →
    conclusion, and picks a lever. No model needed: every statement is already
    analysed, so the type follows by rule. Here the player does the
    #l("explainer-pta")[ATIP] typing, and that's the learning.
- *Carrying over.* A new run keeps some highlights, texts and conclusions.

== Runtime pieces

```mermaid
flowchart LR
  subgraph Assets["content (RON)"]
    TXT[("texts + spans")]
    SB[("statement bank")]
    NPC[("NPC repertoires")]
  end
  subgraph Quell["Quell services"]
    RD["reading"]
    ARG["argue: editor<br/>or free-text parse"]
    DB["debate"]
    DL["dialogue"]
  end
  CORE["q_pta (pure Rust):<br/>derive_code, lever options"]
  TXT --> RD --> ARG
  SB --> ARG --> DB
  NPC --> DB
  DB --> CORE
  DB --> DL
  click ARG href "debate-spike.html"
  click DB href "debate-evaluation.html"
```

- *`q_pta`:* a pure library crate with the PTA table and a port of the
  editor's `deriveCode` and `leverOptions`, checked against `ra-inputs.json`.
  A new `lib/` crate also needs its own skill and a `q-os` map entry.
- *Assets:* an exporter turns reviewed maps into RON: texts and spans, the
  statement bank, NPC repertoires.
- *Dialogue:* `misc/labs/nlp/examples/*.yarn` sketch it in Yarn.
  `bevy_yarnspinner` isn't evaluated yet.
- *Layout:* `services/{reading,notes,debate}`, `screens/debate`, per
  `bin/quell/docs/architecture.md`. Tweakables are Resources.

== Structure, not judgement

For now the game only checks *structure*: does the argument have a type, and
does the lever fit it? Whether it's _good_, and who wins, is
#l("debate-evaluation")[later research].

#open[How does the game stop brute force when the player can try every pair of
statements? Ideas: a cost per submission, feedback that names the kind of
failure but not the fix, confirming in batches. Settle by playtesting.]
