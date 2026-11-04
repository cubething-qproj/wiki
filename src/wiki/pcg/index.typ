#import "../../template.typ": *
#show: article.with(
  title: [Procedural generation],
  summary: [How Quell builds exploration spaces and changes the routes through them.],
)

Quell's exploration spaces separate the landscape from the landmarks and paths
arranged over it.

= Start here

+ Read #l("terrain-generation") for the landscape pipeline and the distinction
  between fixed ground and replaceable layouts.
+ Continue to #l("trail-layout") for landmarks, route constraints and regeneration.

The generator runs today in a development screen, where boards can be
generated and inspected. Turning it into playable levels is still a proposal.

#wip("quell-world-generation-design")[Generated terrain is not yet part of the
playable world.]

= Topics

#article-list("pcg")

= Development records

Proposals and implementation history live in the separate
#link("/documents/pcg.html")[PCG document library]. They are supporting records,
not prerequisites for reading the topic articles.
