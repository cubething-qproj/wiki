#import "../../template.typ": *
#show: article.with(
  title: [Abstract argumentation],
  summary: [Dung's model of a debate as a graph of attacks, and how to decide which arguments survive.],
  documents: ("debate-evaluation",),
)

*Abstract argumentation*, introduced by Phan Minh Dung in 1995, models a
debate as a directed graph. Each node is an argument, and an arrow from $A$ to
$B$ means "$A$ attacks $B$". The model deliberately ignores what the arguments
say. It asks only which arguments can stand together, given who attacks whom.
It is a candidate for deciding who wins a debate in Quell. See
#l("debate-system#debate-judging").

#contents()

= Acceptance <dung-acceptance>

An argument is *acceptable* if every argument attacking it is itself
defeated by an accepted argument. A set of arguments that can all be accepted
together is called an *extension*. There are several ways to choose one. The
most cautious is the *grounded extension*, which accepts only what is beyond
dispute:

+ Accept every argument that nothing attacks.
+ Reject every argument attacked by an accepted one.
+ Repeat, until nothing changes.

Arguments left neither accepted nor rejected, as in a cycle of mutual attacks,
stay undecided.

```mermaid
flowchart RL
  C["C: player undercuts the counter"]:::acc --> B["B: NPC's counter"]:::rej
  B --> A["A: player's rebuttal"]:::acc
  A --> N["NPC's thesis"]:::rej
  classDef acc fill:#dcfce7,stroke:#166534,color:#111
  classDef rej fill:#fee2e2,stroke:#991b1b,color:#111
```

In this example, nothing attacks C, so C is accepted (green). C defeats B, so
B is rejected (red). A's only attacker has been defeated, so A is accepted, and
the thesis A attacks is rejected.

= In Quell <dung-quell>

Under this model, winning a debate could mean that the character's thesis is
outside the grounded extension: the player has made an attack that the
character cannot answer. The computation is a simple loop, so its cost is
negligible at the scale of a conversation.

#wip("debate-evaluation")[How a debate is won has not been designed. Abstract
argumentation is one of several candidates, along with
#l("explainer-capna")[CAPNA] and #l("explainer-value-based")[value-based
argumentation].]

= See also <dung-see-also>

- #l("explainer-value-based") — an extension in which attacks depend on what
  the audience values.
- #l("debate-system") — the mechanic this would serve.

= References <dung-references>

- Dung, P. M. (1995). On the acceptability of arguments and its fundamental
  role in nonmonotonic reasoning, logic programming and _n_-person games.
  _Artificial Intelligence_, 77(2), 321–357.

= External links <dung-external>

- #link("https://en.wikipedia.org/wiki/Argumentation_framework")[Argumentation framework]
  — an overview of Dung's model and its semantics.
- #link("https://arg.tech/research/dung-o-matic/")[Dung-O-Matic] — ARG-tech's
  Java implementation.
