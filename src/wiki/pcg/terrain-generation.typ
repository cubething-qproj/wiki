#import "../../template.typ": *
#show: article.with(
  title: [Terrain generation],
  summary: [How Quell creates fixed ground for a changing trail network.],
  documents: ("quell-hex-terrain-r11-design", "hex-paths-overview", "quell-world-generation-design"),
)

Quell's terrain generator creates the ground beneath its exploration spaces.
The essential separation is between the *landscape*, which stays fixed, and
#l("trail-layout")[the landmarks and trails], which can be regenerated over it.
This article describes the generator as it runs in the hex-path development
screen.#footnote[
  Implementation checked against `bin/quell/src/screen/dev/hex_paths/terrain/mod.rs`
  and `data/board.rs` in the same screen. The world-streaming proposal is a separate
  #doc("quell-world-generation-design")[design document].]

#contents()

= From landscape to playable ground <terrain-pipeline>

Generation works from large to small:

+ *Simulate a region.* Erosion produces a larger landscape with heights,
  downhill drainage and catchment areas.
+ *Choose a window.* Candidate board locations are compared for features such
  as creeks, crossing opportunities and views.
+ *Sample the terrain.* The chosen ground is sampled onto a hex mesh, with
  scores indicating suitable landmark sites.
+ *Build a layout.* Landmarks and routes are arranged over that ground.

```mermaid
flowchart TD
  REGION["Eroded region"] --> WINDOW["Chosen window"]
  WINDOW --> TERRAIN["Fixed terrain"]
  TERRAIN --> LAYOUT["Replaceable landmarks and trails"]
  LAYOUT --> BOARD["Board preview"]
```

The larger region gives the selected board a landscape context: its creeks are
parts of a drainage system rather than lines drawn solely to fit the trails.
Window selection then looks for useful places within that landscape. The
terrain module documents both stages and their relationship.#footnote[
  `terrain/erosion.rs`, `terrain/window.rs`, and the module documentation in
  `terrain/mod.rs`, under `bin/quell/src/screen/dev/hex_paths/`.]

#gallery(
  caption: [Regional-terrain experiments from the Python prototype (experiment 08).
    These historical comparisons illustrate the landscape model, not the current
    game's rendered appearance. Click an image to inspect it at full resolution.],
  media(
    "/media/pcg/experiments/08-region/terrain-seed-2.png",
    alt: "Four prototype terrain variants for seed 2, showing contours and blue creek routes.",
    caption: [Seed 2: compare the baseline and regional variants.],
  ),
  media(
    "/media/pcg/experiments/08-region/terrain-seed-7.png",
    alt: "Four prototype terrain variants for seed 7, showing how the same settings produce different landscapes.",
    caption: [Seed 7: another landscape under the same comparison.],
  ),
)

= Ground and routes are different geometries <terrain-geometries>

The hex mesh serves two purposes. Trails follow hex sides, connecting corners.
Creeks connect tile centres. A creek can therefore cross a potential trail
edge; the layout treats those crossings as routing constraints and provides
crossing locations where appropriate.

This distinction matters when reading a diagram: a creek and a trail do not
use the same network, even though both are drawn on the same board.

= What remains fixed <terrain-fixed>

A board owns the selected terrain and its current layout. The terrain retains
the original ground heights. The layout works on a copy, which can be levelled
around landmark pads. Replacing the layout begins from the original terrain,
so a removed landmark need not leave its old flattened pad behind.#footnote[
  `Terrain` and `Board` ownership is documented in `terrain/mod.rs` and
  `data/board.rs`; the height copy is documented on `Layout` in
  `layout/arrangement.rs`, under the hex-path screen.]

See #l("trail-layout") for what regeneration preserves and replaces.

= Beyond the development preview <terrain-future>

In the playable world, the coarse landscape would be generated once per
level, and finer ground and other detail would be generated in chunks near the
player.

#wip("quell-world-generation-design")

#undecided[Chunk size and level-of-detail distances. The world-generation
proposal leaves both to later tuning.]

= See also <terrain-see-also>

- #l("trail-layout") — landmarks, routes and regeneration.
- #l("portal-pcg") — the procedural-generation portal.

= External links <terrain-external>

- #link("https://en.wikipedia.org/wiki/Drainage_basin")[Drainage basin] — background
  on the landscape structure represented by catchment areas.
- #link("https://en.wikipedia.org/wiki/Erosion")[Erosion] — general background,
  not a specification of Quell's simulation.
