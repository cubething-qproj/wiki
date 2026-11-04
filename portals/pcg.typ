#import "../_template.typ": *
#show: article.with(
  title: [Procedural generation],
  summary: [How Quell builds exploration spaces and changes the routes through them.],
)

Quell's exploration spaces separate the landscape from the landmarks and paths
arranged over it. This portal introduces that model without requiring the
history of each generator experiment.

= Start here

+ Read #l("terrain-generation") for the landscape pipeline and the distinction
  between fixed ground and replaceable layouts.
+ Continue to #l("trail-layout") for landmarks, route constraints and regeneration.

These articles describe the hex-path development implementation and distinguish
it from proposals for the playable world. They are explanations, not a project
plan or an API reference.

= Topics

#article-list("pcg")

= Development records

Proposals and implementation history live in the separate
#link("/documents/pcg.html")[PCG document library]. They are supporting records,
not prerequisites for reading the topic articles.
