#import "../../template.typ": *
#show: wiki-page.with(
  title: [Evaluation: later research],
  status: "draft",
  summary: [Judging arguments: CAPNA, Dung, values.],
)

#note[Not designed. The current focus is argument structure.]

Typing says _what kind_ of argument something is. Evaluation says whether it's
good, and who wins the debate. These are the leads to research later:

- *#l("explainer-capna")[CAPNA]* (Hinton and Wagemans): judging an
  argument in stages. `capna-based-flow.md` sketches response categories from
  it.
- *#l("explainer-dung")[Dung's abstract argumentation]*: arguments as a
  graph of attacks; "winning" as which arguments survive.
  - Dung-O-Matic and Dungine, Java implementations from ARG-tech:
    #link("https://arg.tech/research/dung-o-matic/")
- *#l("explainer-value-based")[Value-based argumentation]*
  (Bench-Capon 2003): each NPC ranks values, so the same argument can win
  against one NPC and fail against another. Ada will get the paper.

#undecided[What counts as winning a value debate? Is losing because an NPC ranks
values differently satisfying, or does the game need to say so ("you won't
move me on liberty")?]
