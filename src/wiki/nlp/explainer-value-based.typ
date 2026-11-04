#import "../../template.typ": *
#show: article.with(
  title: [Value-based argumentation],
  summary: [An extension of abstract argumentation in which whether an attack succeeds depends on what the audience values.],
  documents: ("debate-evaluation",),
)

*Value-based argumentation*, proposed by Trevor Bench-Capon in 2003, extends
#l("explainer-dung")[abstract argumentation] with *values*. Each argument
promotes a value, such as liberty, order or piety. Each *audience* ranks those
values. An attack succeeds against an audience only if that audience does
not rank the attacked argument's value above the attacker's.

The result is that the same argument can persuade one listener and fail
with another, without either being simply wrong. Practical and moral
disagreements often work like this. Two people can accept all the same facts
and still disagree about what should be done, because they weigh the values at
stake differently.

= In Quell <value-quell>

Value-based argumentation suits a game about philosophical debate. Each
character's ranking of values could be part of their personality. The same
argument would then win against one character and fail against another, and the
game would never have to declare any value judgement true.

Whether losing on values would feel fair to the player is one of the
#l("debate-system#debate-open")[open questions] about debate.

= See also <value-see-also>

- #l("explainer-dung") — the underlying model.
- #l("debate-system") — the mechanic this would serve.

= References <value-references>

- Bench-Capon, T. J. M. (2003). Persuasion in practical argument using
  value-based argumentation frameworks. _Journal of Logic and Computation_,
  13(3), 429–448.
