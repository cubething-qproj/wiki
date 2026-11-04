#import "../../template.typ": *
#show: wiki-page.with(
  title: [PTA and ATIP],
  status: "current",
  summary: [The Periodic Table of Arguments: 50 argument types.],
)

In the *Periodic Table of Arguments* (Wagemans, v3.1), an argument is
three statements: a *conclusion*, a *premise*, and a usually unstated
*lever* saying _how_ the premise supports the conclusion. Each statement
has a subject and a predicate. The type follows from:

- *form*, what conclusion and premise share. α: the subject ("a is X
  because a is Y"). β: the predicate ("a is X because b is X"). γ:
  nothing. δ: a whole proposition ("q is acceptable because Z said q").
- *substance*: statement kinds for α (fact, value, policy: F/V/P);
  subject scope for β (singular, particular, universal: s/p/u); i/d for
  γ; perspective (I/II/III) for δ.
- *lever*, named by a keyword: CAUSE, EXAMPLE, ANALOGOUS…

A type is written as a code like `α FF Cau`. *ATIP* (v6) finds it in six
steps: label, reformulate, form, substance, lever, name. The editor
derives form and substance by rule from the canonical statements; only
the lever is chosen.

See the `pta-atip` skill and `.docs/reference/`.
