#import "../../template.typ": *
#show: wiki-page.with(
  title: [Dung's abstract argumentation],
  status: "current",
  summary: [A debate as a graph of attacks; who survives.],
)

Dung (1995) treats a debate as a directed graph. Nodes are arguments; an
edge A → B means "A attacks B". An argument is *accepted* if every
attack on it is defeated by an accepted argument.

The most cautious accepted set, the *grounded extension*, comes from a
simple loop: accept everything unattacked, reject what those attack,
repeat. It's cheap at game scale.

Implementations: Dung-O-Matic and Dungine (Java, ARG-tech),
#link("https://arg.tech/research/dung-o-matic/").
