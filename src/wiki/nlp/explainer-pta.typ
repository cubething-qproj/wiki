#import "../../template.typ": *
#show: article.with(
  title: [Periodic Table of Arguments],
  summary: [Wagemans' classification of arguments into 50 types by form, substance and lever, and the procedure for finding a type.],
  documents: ("pta-atip-algorithm", "pta-atip"),
)

The *Periodic Table of Arguments* (PTA) is a classification of arguments
devised by the argumentation theorist Jean Wagemans. Like the chemical periodic
table, it does not list types by name. Instead, it arranges them by a few
underlying properties, and a type's place in the table follows from those
properties. Version 3.1 has 50 types. The accompanying *Argument Type
Identification Procedure* (ATIP) is a step-by-step method for finding the type
of a real argument.

Quell uses the PTA to describe the structure of the arguments in its texts.
The plan is for players to build arguments out of statements they have read,
and for the game to recognize what kind of argument they have made. See
#l("argument-maps") and #l("debate-system").

#contents()

= Three statements <pta-statements>

In the PTA, a single argument consists of three statements:

- a *conclusion*, the claim being argued for;
- a *premise*, the reason given for it;
- a *lever*, which says _how_ the premise supports the conclusion.

The lever is almost never stated. In "The minister did a great job, because
she raised the university budget", the unstated lever is roughly "raising the
budget is a criterion for doing a great job".
Making the lever explicit shows what an objection would have to attack.

Each statement is analysed into a *subject*, what it is about, and a
*predicate*, what is said about it. The type follows from comparing the
subjects and predicates of the conclusion and the premise.

= Form <pta-form>

The *form* records what the conclusion and premise have in common. Letters
stand for subjects ($a$, $b$) and predicates ($X$, $Y$).

#table(
  columns: (auto, auto, 1fr),
  table.header([Form], [Pattern], [Example]),
  [α (alpha)], [$a$ is $X$ because $a$ is $Y$],
  [The minister did a great job, because she raised the university budget.],
  [β (beta)], [$a$ is $X$ because $b$ is $X$],
  [Cycling on the lawn is prohibited, because all activities on the lawn are prohibited.],
  [γ (gamma)], [$a$ is $X$ because $b$ is $Y$],
  [Peace can be started by the truth, because war can be started by lies.],
  [δ (delta)], [$q$ is acceptable because $q$ is $Z$],
  [The economy has grown, because Eurostat says so.],
)

In α and β, the shared element must be shared _literally_, which is why
rewording matters. δ is different: its subject is a whole proposition $q$,
and the argument rests on its source. Appeals to expertise, popularity,
threats and personal attacks all have this form.

= Substance <pta-substance>

The *substance* refines the form. What it describes depends on the form, and it
is always written conclusion first:

- *α*: the kind of each statement: *F* (fact), *V* (value) or *P* (policy).
  The minister example is *VF*: a value judgement supported by a fact.
- *β*: the scope of each subject: *s* (singular), *p* (particular, "some")
  or *u* (universal, "all"). The lawn example is *su*.
- *γ*: whether the two relations are *i* (identical, as peace is to war as
  truth is to lies) or *d* (different).
- *δ*: whose authority the premise invokes: *I* (the arguer's own), *II*
  (the listener's, as in threats or rewards) or *III* (a third party, such as
  an expert).

= Lever <pta-lever>

The *lever* names the relationship that does the work. Each combination of
form and substance permits only certain levers. A few examples:

- α *FF*: the premise is a *sign*, *cause* or *effect* of the conclusion.
- α *VF*: the premise is a *criterion* or *definition* of the conclusion.
- α *PF*: the premise is a *pragmatic motivation*, as in "we should do this,
  because it works".
- β *ss*: one subject is *analogous*, *similar* or *equal* to the other.
- β *us*: the premise subject is an *example* of the conclusion's subject.
- δ *III*: the source is *epistemically*, *morally* or *popularly*
  authoritative.

A type is written as a code combining all three, such as `α FF Cau`
(argument from cause) or `β ss A` (argument from analogy). The full table is
on the PTA website.

= Identifying a type <pta-atip>

ATIP (version 6) works through six steps:

+ *Label* the conclusion, premise, subjects and predicates in the text,
  along with markers such as "because" or "I think".
+ *Reformulate* the argument as "conclusion because premise". Resolve
  pronouns, add what is implied, and reword so that shared terms are
  literally the same.
+ Determine the *form*.
+ Determine the *substance*.
+ Choose the *lever*, from the options the form and substance allow.
+ *Name* the type.

The second step needs the most judgement. Whether two phrases count as "the
same subject" is an interpretive decision, and the form depends on it.

= In Quell <pta-quell>

In the lab's argument-map editor, steps 3 and 4 are mechanical. Once each
statement has been reformulated and analysed, the editor derives the form and
substance by rule, and the annotator chooses only the lever. The same rules
would let the game type a player's argument without a language model,
provided the player builds it from statements that have already been analysed.
#footnote[The derivation rules and their test cases are in
`misc/labs/xAIF/README.md` and `examples/ra-inputs.json`. A formalization of
ATIP as rules plus statistical judgements is in
#doc("pta-atip-algorithm")[ATIP as an algorithm].]

#undecided[Whether 50 types is too many to teach in a game. One option is to
show players broad families of lever (cause, example, analogy, authority) and
keep the full codes internal.]

= See also <pta-see-also>

- #l("explainer-iat") — the framework for mapping whole texts, in which PTA
  types label individual inferences.
- #l("explainer-capna") — judging whether an argument is good, not just what
  type it is.
- #l("argument-maps") — how Quell's maps combine IAT and the PTA.

= References <pta-references>

- Wagemans, J. H. M. (2026). _Argument Type Identification Procedure (ATIP),
  Version 6_. Aligned with PTA 3.1.
- Hinton, M., & Wagemans, J. H. M. (2021). Evaluating reasoning in natural
  arguments: A procedural approach. _Argumentation_.
  #link("https://doi.org/10.1007/s10503-021-09555-1")[doi:10.1007/s10503-021-09555-1].

= External links <pta-external>

- #link("https://periodic-table-of-arguments.org/")[The Periodic Table of Arguments]
  — the official site.
- #link("https://www.periodic-table-of-arguments.org/pta-3-1-clickable")[PTA 3.1, clickable]
  — worked examples of all 50 types.
- #link("https://www.periodic-table-of-arguments.org/argument-type-identification-procedure")[ATIP]
  — the identification procedure.
