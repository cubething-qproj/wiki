#import "../../template.typ": *
#show: article.with(
  title: [Procedural generation],
  summary: [How Quell builds exploration spaces and changes the routes through them.],
  authors: ("GPT Sol",),
  date: "2026-11-03",
)

Quell's exploration spaces separate the landscape from the landmarks and paths
arranged over it. The generator runs in a development screen, where boards can
be generated and inspected.

Start with #l("terrain-generation"), which covers the landscape pipeline and
the difference between fixed ground and replaceable layouts. Then read
#l("trail-layout") for landmarks, route constraints and regeneration.

#wip(
  "quell-world-generation-design",
)[Covers: generated terrain in the playable world.]

= Topics <pcg-topics>

#article-list("pcg")

= Records <pcg-records>

Proposals and implementation history are in the
#link("/documents/pcg.html")[PCG document library].

= See also <pcg-see-also>

- #l("research-labs") — hex-lab, where the generator was prototyped.
- #l("portal-gameplay-3d") — the player and cameras that would explore these spaces.
