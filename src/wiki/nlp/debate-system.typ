#import "../../template.typ": *
#show: article.with(
  title: [Debate],
  summary: [The planned mechanic in which players read real philosophy, build arguments and debate NPCs.],
  documents: (
    "debate",
    "debate-game",
    "debate-open",
    "debate-evaluation",
    "debate-arms",
    "capna-based-flow",
  ),
)

Debate is Quell's planned central mechanic. Players read in-world texts, which
are excerpts of real philosophy. They highlight and take notes, build
arguments from what they have found, and debate non-player characters on
questions without easy answers. Some debates must be won to progress; others
only change the conversation. Between runs, players keep only what they have
learned, as in a knowledge-based roguelite.

#wip("debate", "debate-game")[Quell has no reading, debate or dialogue code.
What follows is design intent, supported by research in the labs. The plan is
a draft, and several of its basic choices are still open.#footnote[The current
plan is the draft-2 plan map of 2026-11-03, which supersedes the first roadmap
in `.docs/designs/quell-debate-roadmap.typ`.]]

#contents()

= The player's loop <debate-loop>

```mermaid
flowchart TB
  READ["read in-world texts"] --> HL["highlight and take notes"]
  HL --> BANK[("collected statements")]
  BANK --> ARGUE["build an argument"]
  ARGUE --> DEB["debate an NPC"]
  DEB -->|NPC answers| ARGUE
  DEB -->|win or move on| NEXT["next area or run"]
  NEXT -->|keep what you know| READ
```

- *Reading.* A highlight snaps to a statement that has already been
  identified in the text's #l("argument-maps")[argument map], so the game
  always knows which statement the player chose. Notes remain free text; see
  #l("reading-notes").
- *Arguing.* Two forms of input will be tried, to see how each feels:
  - in a *thinking editor*, the player links a premise to a conclusion and
    picks the kind of connection;
  - with *free text*, the player types and a model parses the argument.
- *Carrying over.* A new run keeps some highlights, texts and established
  conclusions, which can open new conversations.

The thinking editor needs no language model during play. Every collected
statement is analysed in advance, so the argument's type can be derived by
rule. The player performs the classification, and that is where the learning
happens. Free-text input is attractive, but it depends on a model that can
parse arguments quickly enough on the player's machine.

= Analysis at authoring time <debate-authoring>

The texts are analysed offline. Each excerpt becomes an argument map: its
statements, how they connect, and the type of each argument under the
Periodic Table of Arguments. Models and agents may *propose* maps, but a
person reviews each one in the xAIF editor. Reviewed maps serve two purposes.
They are game content, and they are the gold standard used to score automated
approaches.

So the game does not need an automatic analysis pipeline in order to exist.
Hand-made maps are enough for a playable debate. A pipeline would mainly make
authoring faster, unless it proves fast enough to parse players' free text at
runtime. The next planned experiment, a "spike", tests whether a small local
model on a CPU can write valid maps at all.#footnote[#doc("debate-spike")[Spike:
natural language → xAIF], proposed and not yet reviewed. The alternatives it
will be compared against are listed in #doc("debate-arms")[Arms and decisions].]

= Constraints <debate-constraints>

- *Local models in the game.* No cloud model may run during play. Cloud models
  and agents are acceptable for authoring and labelling.
- *Modest hardware.* The plan must not depend on a strong GPU.
- *No subscription.* The game is free or bought once.
- *One developer.* Anything that needs a team to maintain is ruled out.
- *Real books.* The source texts are not committed or published by the labs.
  Whether they can be shipped is a separate question for each text.

= Structure first, judgement later <debate-judging>

At first, the game will check only an argument's *structure*: whether it has a
recognizable type, and whether the chosen connection fits that type. Whether
an argument is *good*, and who wins, is later research. The leading
candidates are:

- *CAPNA*: judging an argument in stages (relevance, reasoning, language).
  Each type of argument has its own critical questions, which could become
  what the NPC says in reply;
- *Dung's abstract argumentation*: a debate as a graph of attacks, in which
  the arguments that survive are the ones that win;
- *value-based argumentation*: each NPC ranks values, so the same argument
  can succeed against one character and fail against another.

Each has its own article: #l("explainer-capna"), #l("explainer-dung") and
#l("explainer-value-based").

#undecided[How a debate is won. Is it satisfying to lose because an NPC ranks
values differently, or must the game say so explicitly?]

#undecided[Whether players argue in free text, in the thinking editor, or
both. This depends partly on whether runtime parsing works.]

#undecided[How the game prevents brute force when a player could try every
pair of statements. Ideas include a cost per submission, feedback that names
the kind of failure but not the fix, and confirming in batches.]

#undecided[Whether the PTA's 50 argument types are too many to teach. The
editor could show broad families of connection and keep full codes internal.]

= Where it would live in Quell <debate-in-quell>

The draft plan sketches reading, notes and debate services, a debate screen,
and content exported from reviewed maps as RON assets. It also proposes a
small pure-Rust crate (working name `q_pta`) for the type table and derivation
rules, checked against the same conformance examples as the editor. Dialogue
has been sketched in Yarn, but `bevy_yarnspinner` has not been evaluated for
Quell.#footnote[#doc("debate-game")[Quell integration], a sketch. The visual
novel `vn-jun-26` already uses `bevy_yarnspinner`, but that is a separate game.]

= See also <debate-see-also>

- #l("argument-maps") — what an argument map contains and how one is made.
- #l("reading-notes") — interpreting the player's highlights and notes.
- #l("research-labs") — the labs where this work happens.

= External links <debate-external>

- #link("https://periodic-table-of-arguments.org/")[Periodic Table of Arguments]
  — Wagemans' classification of argument types.
- #link("https://en.wikipedia.org/wiki/Argumentation_framework")[Argumentation framework]
  — background on Dung's abstract model.
