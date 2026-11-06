#import "../../template.typ": *
#show: wiki-page.with(
  title: [Quell story progression: design],
  status: "draft",
  authors: ("Ada", "Claude Opus 5.5"),
  date: "2026-11-06",
  summary: [The guilt loop, the way out of it, and how beliefs gate the
    story.],
)

#note[Early sketch, started from a conversation; expect it to change. The
  belief model it builds on is #l("npc-stances-data-model").]

== The loop

Each run follows the story graph to the eye in the sky, which asks two
questions: _"Has she forgiven you?"_ and _"Have you forgiven yourself?"_
Whatever the player answers, the eye says _"Then you must try again,"_ and
the player is sent back to the beginning with their beliefs and knowledge
intact.

```mermaid
flowchart LR
  START["beginning"] --> GRAPH["story graph<br/>(gated by beliefs)"]
  GRAPH --> EYE{"the eye:<br/>has she forgiven you?<br/>have you forgiven yourself?"}
  EYE -->|"yes or no"| AGAIN["'then you must try again'"]
  AGAIN -->|"Stances and Inventory kept"| START
  EYE -.->|"the questions no longer hold"| OUT["the eye disappears:<br/>letting go"]
```

The goal is to get out of the guilt cycle: for the eye to disappear from
sight. There is no perfect outcome, because none exists. The player can't
change what was done, heal the wounds, or fix the world. The way out is to
let go, much as the true ending of _Sovereign Tower_ is to destroy the
tower and let the people decide their own fates, not to make war or peace.

== Letting go is aporia

Answering yes or no is still holding a stance (Affirm or Deny), so either
answer keeps the player in the loop. The way out is when the questions no
longer have a grip: the stances they ask about are `Suspended`.

Suspension can't be chosen. It comes only through argument, by
#l("npc-stances-data-model#npc-stances-aporia")[elenchus or equipollence],
once the player has committed to enough beliefs for them to collide. So:

- it comes late without being scripted as late;
- a player who never commits to anything stays in the loop, because a
  missing stance isn't a suspended one. This is aporia, the release of
  dukkha, not passivity;
- arguing is required. Winning arguments isn't the point, but there's no
  way out without them.

#anchor("story-ladder")
=== The ladder

"Held, then lost" is Wittgenstein's ladder: _"My propositions serve as
elucidations in the following way: anyone who understands me eventually
recognizes them as nonsensical, when he has used them — as steps — to climb
up beyond them. (He must, so to speak, throw away the ladder after he has
climbed up it.)"_ (_Tractatus_ 6.54). The player's beliefs are the rungs.
They have to be climbed: held, argued for, set against each other. Only
then can they be thrown away. A player who never climbs has nothing to
throw away.

The Buddha's raft makes the same point: the teaching is a raft for crossing
the river, not something to carry on your head once you've crossed (MN 22,
_Alagaddūpama Sutta_).

== Wrong questions

_"Has she forgiven you?"_ and _"Have you forgiven yourself?"_ are wrong
questions. They aren't hard to answer; they're the wrong thing to be asking.
Each is an instance of clinging (_upādāna_): to her verdict, to a self that
judges and is judged, to guilt as a debt that could be settled. Clinging is
what produces dukkha, so the questions don't describe the suffering; they
_are_ it. That's why every answer leads back to the start: answering
accepts the question.

The Buddha set some questions aside in the same way. In the parable of the
poisoned arrow (MN 63, _Cūḷamālukya Sutta_), a wounded man who won't let the
arrow be removed until he knows who shot it dies with his questions
answered by no one. MN 2 (_Sabbāsava Sutta_) lists questions about the
self ("Did I exist in the past? What am I?") as unwise attention that ends
in a thicket of views.

In the belief model, a wrong question rests on statements it takes for
granted (its presuppositions). Answering it affirms them; the way out is
suspending them. The eye's questions are only the surface. What has to
loosen is what they presuppose.

#undecided[Which presuppositions does the ending check (for example "guilt is a
  debt", "her forgiveness decides my worth")? All of them, or enough of
  them? Are they authored per question, or discovered in play?]

#undecided[Does the eye change as the player's stances loosen: fewer
  questions, different wording, less presence? Or is the disappearance
  sudden?]

== The story graph

Within a run, the story is a directed graph read left to right. Branches
converge again, so it's a DAG, not a tree. Nodes are events and story
beats; edges are gated by conditions on beliefs:

- *mostly the player's* `Stances`, which are the record of their change of
  mind and carry over between runs;
- *NPC stances only locally*: what an NPC does, says or is willing to talk
  about. They may not need to touch the story graph at all.

The graph resets each run; the beliefs don't. A later run can open paths an
earlier one couldn't, because the player now holds (or no longer holds)
something.

#undecided[What does a gate look like? A single stance ("affirms X is Y"), a
  set, a contradiction among the player's stances, or a count?]

#undecided[Does the graph itself change between runs, or only which of its
  paths are open?]

== Decisions are offered, not argued

Debates settle what is the case and how good or bad it is (F and V
statements); they never settle what to do. Decisions are separate: when
someone asks the player what to do, the player picks from a few authored
choices built from the conversation so far, as in _Sovereign Tower_. The
player can't make one up. Otherwise the game would need an open-ended
space of _behaviour_ on top of the space of beliefs.

NPCs mostly decide for themselves based on their own beliefs. Asking the
player directly should be rare, reserved for NPCs who trust the player's
judgement.

#undecided[What is trust in the model: a stance, a separate value per NPC, or
  a story-graph condition?]

#undecided[The point of changing beliefs is to change behaviour. How do an
  NPC's beliefs turn into what it does: authored per NPC, or gates in the
  story graph?]

== See also <story-see-also>

- #l("npc-stances-data-model") — stances, `Suspended`, and elenchus and
  equipollence as the routes to aporia.
- #l("debate-system") — the debate mechanic: reading, arguing, carrying
  over between runs.
- #l("debate-game") — the player's loop in Quell.
- #l("explainer-value-based") — why an NPC who ranks values differently may
  never be moved, and whether losing that way is satisfying.
