#import "../../_template.typ": *
#show: article.with(
  title: [Trail layout and regeneration],
  summary: [Landmarks and changing routes over Quell's fixed terrain.],
  documents: ("quell-hex-terrain-r11-design", "quell-hex-layout-design", "hex-paths-overview"),
)

A *layout* is an arrangement of landmarks and trails over
#l("terrain-generation")[fixed terrain]. Keeping those layers separate allows
Quell to change the route network without replacing the underlying landscape.
The hex-path development screen implements this separation; it should not be
read as a claim about every future exploration mechanic.#footnote[
  Implementation checked against `bin/quell/src/screen/dev/hex_paths/layout/mod.rs`,
  `layout/arrangement.rs`, and `data/board.rs`.]

#contents()

= Landmarks and trails <layout-landmarks>

Landmarks include points of interest, benches and creek crossings. Generation
places these locations, prepares their pads, and connects them with trails.
The route network must respond to the ground and creek barriers, rather than
assuming every nearby pair of landmarks has a direct connection.

Some connections are deliberately indirect. A *tease* pairs a viewer with a
visible point of interest while trying to preserve a longer walk to reach it.
Seeing the destination and having a short route to it are different things.

= Regeneration <layout-regeneration>

Regeneration rebuilds a layout over the same terrain. It can preserve selected
landmarks and trails through *pins*. Preserved trail ends become connections
that the new network must repair. The layout's original-ground copy is renewed,
so old landmark grading is not permanently written into the landscape.

The implementation uses this common pipeline for partial regeneration and
Fear regeneration. What it preserves is represented explicitly by the pins;
regeneration is not simply a fresh board with a different random seed.#footnote[
  See the regeneration and pin descriptions in `layout/mod.rs`, and `Layout` in
  `layout/arrangement.rs`, under `bin/quell/src/screen/dev/hex_paths/`.]

= Intent and limits <layout-limits>

The design goal is *lost but readable*: landmarks help the player orient
without making the route between them obvious. The round-11 design records
this intent and the experiments behind it.#footnote[
  #doc("quell-hex-terrain-r11-design")[Round-11 design], goals and trail-network
  sections. This is a design objective, not a measured claim about player experience.]

Connectivity repairs can conflict with a tease. The implementation retries or
drops broken tease pairs rather than promising that every requested pair will
survive. A layout should therefore be understood as a generated arrangement
with competing constraints, not a guarantee that every design preference is
simultaneously satisfied.#footnote[
  The pipeline and retry/drop behavior are described in the module documentation
  of `bin/quell/src/screen/dev/hex_paths/layout/mod.rs`.]

= See also <layout-see-also>

- #l("terrain-generation") — the landscape that layouts borrow.
- #l("portal-pcg") — the procedural-generation portal.
