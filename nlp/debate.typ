#import "../_template.typ": *
#show: wiki-page.with(
  title: [Quell debate: plan map],
  status: "draft",
  summary: [The plan, as a clickable flowchart.],
)

#note[Draft 2, 2026-11-03. Supersedes `.docs/designs/quell-debate-roadmap.typ`.]

Quell's players practise debating real philosophical questions. They read
in-world texts, take notes, build arguments, and debate NPCs. Between runs they
keep only what they know.

The plan has one current focus: *argument structure*. Can we turn natural
language into an argument map (#l("explainer-iat")[IAT] +
#l("explainer-pta")[PTA], stored as xAIF) well enough, and fast enough, to
use? Judging who wins is #l("debate-evaluation")[later research].

Click a node to open its page.

```mermaid
flowchart TD
  GOLD["Gold maps<br/>hand-made, reviewed"] --> ARMS{{"Which way from<br/>text to map?"}}
  ARMS --> DIRECT["Direct generation<br/>NL → JSON"]
  ARMS --> ORACLE["Oracle pipeline<br/>rules + small models"]
  DIRECT --> SPIKE["Spike: local, CPU,<br/>few-shot NL → xAIF"]
  SPIKE --> FAST{"Fast and good<br/>enough?"}
  ORACLE --> FAST
  FAST -->|yes| RUNTIME["Parse at runtime:<br/>free-text input possible"]
  FAST -->|no| AUTHOR["Authoring only:<br/>speeds up gold maps"]
  RUNTIME --> GAME["Quell integration"]
  AUTHOR --> GAME
  GAME -.-> EVAL["Evaluation<br/>(later research)"]
  GOLD -. "scores every arm" .-> FAST
  click GOLD href "debate-gold.html"
  click ARMS href "debate-arms.html"
  click DIRECT href "debate-arms.html"
  click ORACLE href "debate-pipeline.html"
  click SPIKE href "debate-spike.html"
  click FAST href "debate-arms.html"
  click RUNTIME href "debate-game.html"
  click AUTHOR href "debate-gold.html"
  click GAME href "debate-game.html"
  click EVAL href "debate-evaluation.html"
  classDef now fill:#fde68a,stroke:#b45309,color:#111
  classDef later fill:#e5e7eb,stroke:#6b7280,color:#111
  class SPIKE now
  class EVAL later
```

The spike (yellow) is the next piece of work.

== Constraints

- *Minimal GPU.* The game stays graphically basic, so models can use some GPU,
  but the plan must not depend on a strong one.
- *Local models first.* No cloud LLMs in the game. Cloud models are fine for
  authoring and gold labelling. Claude and other agents are part of the team.
- *Pricing:* free or a one-time payment, no subscription. Hosting a few dollars
  a month for a modest player base is acceptable.
- *One developer.* Anything that needs a team to maintain is out.
- *The texts are real books.* The lab never commits or publishes them.

== Not decided

- Parse at #l("debate-game")[runtime] or only while authoring: the
  #l("debate-spike")[spike] tests this.
- Free-text input or the thinking editor: both get tried for how they
  #l("debate-game")[feel].
- How a debate is won: #l("debate-evaluation")[evaluation].

See also: #l("debate-phases")[phases], #l("debate-open")[open questions].
