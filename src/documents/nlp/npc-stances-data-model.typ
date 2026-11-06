#import "../../template.typ": *
#show: wiki-page.with(
  title: [NPC stances: data model],
  status: "draft",
  authors: ("Ada", "Claude Opus 5.5"),
  date: "2026-11-06",
  summary: [How characters hold stances on statements and argument families,
    in Bevy terms, and how much has to be written for it to work.],
)

#note[Sketch. Nothing here is built. The working example is
  `misc/labs/yarn-editor/examples/concepts-as-objects/1.yarn`; see
  #l("debate-game") for where this sits in Quell. Everything is hand-authored:
  no language model at play time or for authoring.]

The player collects *statements* ("A is B"), links two of them into an
*argument* ("A is B because C is D") in the thinking editor, and presents it
to an NPC. Every character holds *stances* on statements and on families of
arguments. Responses follow from those stances by rule, so most of the
dialogue is written per _situation_, not per argument.

== The pieces

```mermaid
classDiagram
  direction TB
  class Registry {
    <<Asset / Resource>>
    concepts: ConceptId to name, description
    properties: PropertyId to name, description
    statements: list of Statement
    relations: property or concept pair to LeverFamily
    contraries: property pairs that can't both hold
  }
  class Statement {
    <<value>>
    concept: ConceptId
    property: PropertyId
    predicate: F or V
    subject: s, p or u
  }
  class Argument {
    <<value>>
    conclusion: Statement
    premise: Statement
    form() alpha or beta
    family() LeverFamily or none
  }
  class Stance {
    <<enumeration>>
    Affirm
    Deny
    Suspended
  }
  class Character {
    <<entity>>
  }
  class Stances {
    <<component>>
    statements: Statement to Stance
    families: LeverFamily to Stance
    ranking: value order
  }
  class Inventory {
    <<component, player only>>
    statements
    concepts
    properties
  }
  Registry --> Statement
  Argument --> Statement : conclusion, premise
  Character --> Stances
  Character --> Inventory
  Stances ..> Stance : value
  Argument ..> Registry : family looked up in
```

#table(
  columns: 3,
  table.header([type], [Bevy kind], [why]),
  [`Registry`],
  [RON asset, inserted as a resource once loaded],
  [The authored world of claims: every valid statement with its tags, and
    every meaningful relation between predicates or subjects.],

  [`Statement`],
  [plain `Copy` value with interned ids],
  [A concept–property pair with its PTA tags baked in. F/V is the
    predicate type in context, s/p/u the subject type ("this cup", "some
    cups", "all cups"), so they belong to the statement, not to the concept
    or property.],

  [`Argument`],
  [plain `Copy` value],
  [Two statements. Form and lever family are derived, never stored.],

  [`Stance`],
  [enum, three variants],
  [A missing entry means _never examined_. `Suspended` means _held, then
    lost to argument_ (see #link(<npc-stances-aporia>)[Aporia]). The two are kept apart
    so that never committing to anything can't pass for letting go.],

  [`Stances`],
  [component on every character entity],
  [Authored core beliefs plus opinions on argument families. The player has
    one too; that's how the game tracks the player's own mind.],

  [`Inventory`],
  [component on the player],
  [Statements the player holds. A statement is acquired whole (found in a
    text, heard in dialogue) or composed from a held concept and property,
    but only if the pair is in the registry, so every statement is authored
    and tagged either way.],
)

== Three places to disagree

An argument can be resisted at the conclusion, the premise, or the link
between them (the PTA _lever_). "I agree A is B, but not because of that"
splits in two:

#table(
  columns: 4,
  table.header([the character says], [A is B], [C is D], [the link]),
  ["A is B, but C is not D"], [Affirm], [*Deny*], [—],
  ["A is B, and C is D, but that's not why"], [Affirm], [Affirm], [*Deny*],
)

Statement stances cover the first two columns. Link stances are held per
_lever family_ (cause, example, analogy, authority, …), not per argument:
an NPC who rejects "length makes things great" rejects it for every
concept.

== Form and family

The tags and the registry decide what kind of argument the player made.

*Form* follows from the shared slot: the same concept is α ("a is X because
a is Y"), the same property is β ("a is X because b is X"). A pair sharing
neither is γ, and the thinking editor doesn't accept it (see the counting
below for why).

*Substance* comes from the baked tags: for α the predicate types of
conclusion then premise (FF, FV, VF, VV), for β the subject types (su, ss,
…).

*Lever family*: form and substance narrow the options but don't pick one;
"a is great because a is long" is αVF either way. The lever is the relation
between the two predicates (α) or the two subjects (β), so it's authored once
per related pair in `relations` and reused across every argument that pair
appears in. A pair with no authored relation has no lever: "that has nothing
to do with it."

== How much to write

=== Symbols

#table(
  columns: 2,
  table.header([symbol], [meaning]),
  $S, n = |S|$, [authored statements],
  $k, j$, [number of concepts, number of properties],
  $n_c$, [statements whose concept is $c$],
  $m_p$, [statements whose property is $p$],
  $N$, [number of NPCs],
  $Lambda$, [lever families],
)

=== Arguments the player can make

An argument is an ordered pair (conclusion, premise) of distinct
statements. α pairs share a concept, β pairs share a property. Two distinct
statements can't share both.

$ A_alpha = sum_c n_c (n_c - 1) quad quad A_beta = sum_p m_p (m_p - 1) $

$ A = A_alpha + A_beta quad "out of" quad n(n - 1) "ordered pairs" $

With statements spread evenly ($n_c = n/k$, $m_p = n/j$):

$ A = n (n/k - 1) + n (n/j - 1) $

The growth is quadratic in statements _per concept_ and only linear in the
number of concepts. Adding new concepts is cheap; piling claims onto one
concept is what explodes. Allowing γ would bring back all $n(n - 1)$
pairs, which is the reason to leave it out.

=== Relations (levers)

One relation per related pair of properties sharing a concept, and per
related pair of concepts sharing a property:

$ R <= sum_c binom(n_c, 2) + sum_p binom(m_p, 2) $

This is an upper bound. Most pairs have no meaningful relation and aren't
written. The quadratic term is still here, but it's paid *once* for the
whole game, not once per NPC.

=== One NPC

An NPC is a partial map of core beliefs $sigma_N : S -> {"A", "D"}$, a
partial map of family opinions $rho_N : Lambda -> {"A", "D"}$, and a value
ranking. Presenting the argument (conclusion $x$, premise $y$, family
$lambda$) looks up three values, each Affirm, Deny or missing: $3^3 = 27$
situations. Checked in order, they fall into seven response classes:

#table(
  columns: 4,
  table.header(
    [$sigma(y)$ premise],
    [$rho(lambda)$ link],
    [$sigma(x)$ conclusion],
    [response class],
  ),
  [D], [any], [any], [counter the premise: "C is not D"],
  [missing], [any], [any], [ask for support: "why is C D?"],
  [A], [D], [any], [reject the link: "that's not a reason"],
  [A], [missing], [any], [probe the link: "how does that follow?"],
  [A], [A], [A], [agree: "yes, and…"],
  [A], [A], [missing], [*convinced*: adopts A is B],
  [A], [A], [D], [*conflict*: the value ranking decides],
)

"Ask for support" is how chains happen: the player answers with an argument
whose conclusion is the premise C is D.

`Suspended` counts as missing in this table. Whether a single argument can
re-establish a suspended stance is open (see #link(<npc-stances-aporia>)[Aporia]).

Per NPC, then:

$ W_N = |sigma_N| + |rho_N| + 7v + b $

where $v$ is the number of variants written per response class (slots fill in
the statements) and $b$ the bespoke lines for arguments that matter to the
story.

=== Total

$
  W = underbrace(k + j, "definitions") + underbrace(n, "statements") + R + sum_N W_N
$

Compare writing a response per argument per NPC: $N dot A$, quadratic per
concept _and_ multiplied by every NPC.

=== Worked example: one small debate

20 statements over 5 concepts and 10 properties, evenly spread ($n_c = 4$,
$m_p = 2$), one NPC. That's about one in-world text and one conversation.

#table(
  columns: 3,
  table.header([item], [count], [how]),
  [arguments the player can make], [80 of 380], [$20 dot 3 + 20 dot 1$],
  [definitions], [15], [$5 + 10$],
  [statements], [20], [],
  [relations, at most], [40], [$5 binom(4, 2) + 10 binom(2, 2)$],
  [NPC core beliefs], [~15], [guess],
  [NPC family opinions], [4], [one per family],
  [response variants], [14], [$7 dot 2$],
  [bespoke lines], [~10], [guess],
  [*total*], [*~120 short items*], [],
)

Per-argument writing for the same slice is 80 responses, but every new NPC
adds another 80; under the rule, a second NPC adds about 45.

== Minds that change

Responses are recomputed from the current stances every time, so changing a
stance costs no extra writing for the arguments themselves. What it costs:

- an update rule: _convinced_ sets $sigma(x) = "A"$; _conflict_ consults the
  ranking;
- a few lines per NPC acknowledging a change ("…fine. You've convinced me.");
- testing: which stance states are actually reachable.

The machinery is symmetric. The player has `Stances` too, so an NPC
presenting an argument _to the player_ uses the same model with the roles
swapped, and the player's stances become the record of their change of
mind. Changing NPCs' minds and changing the player's mind can both be tried
on the same data.

=== Ripples and contradictions

A change of mind shouldn't recompute everything (minds become volatile) or
nothing (one belief never touches another). How far it ripples depends on
how much the person knows about the relations between their ideas. Two ways
to model that:

- *Known relations.* Each NPC knows a subset of the registry's relations;
  a change propagates only along those. Authoring is a list of relation ids
  per NPC, and the ripple is derived.
- *Authored ripples.* For each statement an NPC can be convinced of, list
  the stances that change with it. Full control, more writing: one list per
  convincible statement, and the response table shows which those are.

Either way, some beliefs are left behind, and the player can point that
out. That needs a second kind of relation: *contrary* properties, which
can't both hold of the same subject ("is a virtue" / "is a weakness"). An
NPC is inconsistent when it affirms $(c, p)$ and $(c, q)$ with $p$ and $q$
contrary. That's mechanical to find, and the count is small: one check per
contrary pair per concept.

Pointing out an inconsistency isn't δ. δ supports a claim by who says it
("Einstein said so"). "You believe X is Y and X is Z, which can't both be
true" is a *challenge to the NPC's commitments*: a dialogue move, not a PTA
argument type. Dialogue-game theory calls the set of claims a party is
committed to its _commitment store_ (Walton and Krabbe, _Commitment in
Dialogue_, 1995). Recast as an argument, it's α with a negative conclusion
("X is not Y, because X is Z", contrariety as the lever), which needs the
negation question below settled first.

#undecided[Known relations (derived) or authored ripples (controlled)? Or
  known relations by default, with authored overrides for story beats.]

=== Aporia <npc-stances-aporia>

A belief can't be dropped at will. It's dropped when argumentation breaks
its hold: the character can no longer affirm or deny it. That's
`Suspended`, distinct from a missing entry (never examined). "I'm not sure"
early in the game is a missing entry; aporia comes late, and only through
argument. It's a release of dukkha, not passivity.

Two routes lead there, both built on contrary relations:

- *Elenchus* (the Socratic route). Someone shows the character that its own
  stances collide: it affirms $(c, p)$ and $(c, q)$ with $p$ and $q$
  contrary. Neither is simply flipped; both are suspended.
- *Equipollence* (the Pyrrhonist route, Sextus Empiricus's _isostheneia_).
  The character has accepted arguments of equal force on both sides: an
  argument for $(c, p)$ and one for $(c, q)$, $p$ and $q$ contrary. Neither
  wins, so judgement is suspended (_epoché_), and then comes tranquillity
  (_ataraxia_).

Both need accumulated commitments to collide, so aporia can't happen early,
and it can't happen to a character who never committed to anything. Nothing
has to script it as late. The held stances are Wittgenstein's ladder:
climbed, then thrown away (see
#l("quell-story-progression-design#story-ladder")[the ladder]).

For the player, suspended stances are what the ending checks: see
#l("quell-story-progression-design").

#undecided[Can a suspended stance be re-established, and how? By one strong
  argument, never, or only by new evidence?]

#undecided[Does suspension spread to the arguments that relied on the
  suspended statement, along the character's known relations?]

#undecided[What is the game about: changing other people's minds, or the
  player's own (atonement)? Both run on the same model; playtesting decides
  which one carries the story.]

#undecided[Can a premise be negative ("C is not D")? With stances as the only
  polarity, a premise always asserts its statement. A negative premise needs
  polarity on `Statement`, which doubles $n$.]

γ (no shared slot) and δ (arguments from authority, "Einstein said so") are
out: γ for the counting above, δ because a subject would have to be a
statement. Both add complexity the game doesn't need.

P (policy) is out too: statements are F or V. Debates settle what is the
case and how good or bad it is, never what to do. Decisions are authored
choices offered outside the debate, built from the conversation so far;
the player picks one and doesn't make one up. Letting players argue for
policies would mean an open-ended space of _behaviour_ on top of the space
of beliefs. "You shouldn't lie" can still be voiced, typed as the V
statement "lying is wrong".

#undecided[Are subjects always concepts? Restricting them ("justice", "mercy",
  "lies", never "the defendant" or "the council") makes every debate
  philosophical, not scientific debate. Then F statements become conceptual
  ("guilt is a feeling") and most claims are V. The s/p/u tag still works on
  concepts: "all lies", "some lies", and the concept itself.]

== Presenting an argument

```mermaid
flowchart LR
  INV["player Inventory"] -->|pick conclusion, premise| BUILD["build Argument"]
  REG[("Registry")] -->|form, family| BUILD
  BUILD --> NPC["NPC's Yarn node"]
  NPC -->|"response_class(…)"| Q["query system:<br/>reads Stances"]
  Q -->|class| NPC
  NPC -->|"hold_stance, learn_*"| CMD["command systems:<br/>write Stances, Inventory"]
```

Both directions work in `bevy_yarnspinner` 0.9 (vendored in
`bin/vn-jun-26/third_party/YarnSpinner-Rust`). Commands are registered
systems taking `In<T>`, and so are functions:
`examples/bevy_yarnspinner/src/bin/custom_function.rs` registers
`get_counter(counter: Res<Counter>) -> u32` with `add_function`. So a
`response_class` function can read `Stances` directly and the Yarn node
branches on the class. Quell doesn't depend on it yet.

Yarn passes strings, so ids are interned at that boundary and nowhere else.

== Background

The F/V/P split comes from debate theory, where it classifies
_propositions_ by what they ask of the audience. ATIP v6 cites Freeley and
Steinberg, _Argumentation and Debate_ (12th ed., 2009), pp. 55--58; Hinton
and Wagemans also cite Broda-Bahm et al. (2004) and Skorupski (2010). ATIP
applies it to the _predicate_ of an alpha statement, and the s/p/u split
(from Aristotle's _De interpretatione_) to the subject of a beta statement. Quell keeps only F and V.

Which properties fit which concepts is a separate problem, category
mistakes; the closest systematic treatment is Sommers' predicability trees
(_Types and Ontology_, 1963). The registry's statement list is the
hand-authored version of that tree.

== See also <npc-stances-see-also>

- #l("quell-story-progression-design") — how the player's stances gate the
  story, and why the ending checks for suspended stances.
- #l("debate-system") — the debate mechanic this model serves.
- #l("debate-game") — the player's loop, the runtime pieces and `q_pta`.
- #l("explainer-pta") — form, substance and lever, in full.
- #l("pta-cheatsheet") — PTA 3.1 form and substance on one page.
- #l("explainer-dung") — which arguments survive attack; the formal cousin
  of deriving an NPC's responses from its stances.
- #l("explainer-value-based") — attacks that succeed or fail by what the
  audience values: the value ranking that settles a _conflict_.
- #l("debate-evaluation") — earlier notes on judging arguments.
- #l("glossary") — project terms, including the thinking editor.
