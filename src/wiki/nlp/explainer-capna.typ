#import "../../template.typ": *
#show: article.with(
  title: [CAPNA],
  summary: [A procedure for judging the quality of an argument as it appears in natural text.],
  documents: ("capna-based-flow", "debate-evaluation"),
)

The *Comprehensive Assessment Procedure for Natural Argumentation* (CAPNA),
developed by Martin Hinton, is a method for judging whether an argument is
good. The #l("explainer-pta")[Periodic Table of Arguments] says what _kind_ of
argument something is. CAPNA asks whether it _works_. Hinton and Jean Wagemans
later combined the two, using an argument's PTA type to decide which questions
to ask of its reasoning.

= Three aspects <capna-aspects>

CAPNA assesses an argument in three respects:

- *Process*: is the argument relevant to the issue being discussed?
- *Reasoning*: is the premise acceptable, and does the lever hold? Does the
  premise really support the conclusion in the way the argument claims?
- *Language*: are the terms clear, and are they used consistently?

In the combined procedure, each kind of lever has its own questions about
the reasoning. They resemble the traditional *critical questions* of argument
schemes. An argument from analogy invites "is $a$ really like $b$ in the way
that matters?". An appeal to an expert invites "is this source an expert on
this question?".

= In Quell <capna-quell>

Critical questions are a natural fit for dialogue. When a player's argument
is weak, a character could answer with the critical question its type invites.
A response that names the kind of weakness, without supplying the fix, would
also make brute-force guessing less useful.

#wip("capna-based-flow", "debate-evaluation")

= See also <capna-see-also>

- #l("explainer-pta") — the types whose critical questions CAPNA uses.
- #l("explainer-dung") — deciding who wins once the strength of individual
  arguments is known.

= References <capna-references>

- Hinton, M. (2021). _Evaluating the Language of Argument_. Springer.
- Hinton, M., & Wagemans, J. H. M. (2021). Evaluating reasoning in natural
  arguments: A procedural approach. _Argumentation_.
  #link("https://doi.org/10.1007/s10503-021-09555-1")[doi:10.1007/s10503-021-09555-1].
