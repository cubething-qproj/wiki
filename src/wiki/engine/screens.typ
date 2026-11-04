#import "../../template.typ": *
#show: article.with(
  title: [Screens],
  summary: [q_screens' lifecycle for switching between parts of a game, and the entity cleanup that comes with it.],
)

A *screen* is a self-contained part of a game, such as a splash screen, a level
or a development sandbox. It corresponds to a scene or a room in other engines.
The `q_screens` crate gives each screen a load–ready–unload lifecycle. When the
game switches screens, it removes the previous screen's entities. Both of
qproj's games are built on it: Quell and the visual novel `vn-jun-26`.
#footnote[Checked against `lib/q_screens/src/` (version 0.2). The crate's Rust
docs and the `q-screens` agent skill are the API reference.]

The name is unrelated to Bevy's `Scene`, which is serialized entity data.
Quell's screens often spawn Jackdaw scenes.

#contents()

= Defining a screen <screens-define>

A screen is a component type implementing the `Screen` trait. Its builder adds
systems to screen-specific schedules, and the app registers it by type:

```rust
impl Screen for WorldScreen {
    fn builder(mut b: ScreenScopeBuilder<Self>) -> ScreenScopeBuilder<Self> {
        b.add_systems(ScreenSchedule::Loading, load_world);
        b.add_systems(ScreenSchedule::OnReady, init);
        b.add_systems(ScreenSchedule::Update, player_systems().take());
        b
    }
}
```

Per-frame schedules (`Update`, `FixedUpdate`, `Loading` and `Unloading`) run
only while the screen is in the corresponding state. Transition schedules (`OnLoad`,
`OnReady`, `OnUnload` and `OnUnloaded`) run once when the state changes.
Screens are registered by type, and they can also be looked up by name. Quell's
`--screen` option relies on this.

= Lifecycle <screens-lifecycle>

```mermaid
flowchart LR
  U["Unloaded"] --> Q["LoadQueued"]
  Q --> L["Loading"]
  L --> R["Ready"]
  R --> UL["Unloading"]
  UL --> C["Cleanup"]
  C --> U
```

A newly requested screen waits in `LoadQueued` until the previous one has
finished unloading. If a screen has `Loading` systems, one of them must call
`finish_loading()` before the screen becomes ready. Quell's world screen does
this after its player model has loaded. Screens without such systems skip
straight through. By default, `Update` systems wait until the screen is
`Ready`. A non-blocking load strategy lets them run during loading as well.

Loading is the screen's state machine. Services should not build their own
loading states alongside it.

= What gets cleaned up <screens-cleanup>

On cleanup, q_screens despawns *every* entity, except those it is told to keep:

- entities marked `Persistent`;
- entities with a component type registered as persistent. This covers
  Bevy's own windows, observers and resources, and any type a game adds. Quell
  adds the readback entity that Jackdaw's embedded play mode streams through.

Cleanup goes entity by entity, so it does not follow hierarchies. Marking a
parent `Persistent` does not save its children; `Propagate(Persistent)` does.
This is the most common surprise. A camera, UI root or console terminal spawned
at start-up disappears at the first screen change unless it is marked. Quell's
UI camera and console are marked persistent for this reason.

`ScreenScoped` works in the other direction. It overrides `Persistent`, so a
child under a propagated `Persistent` can still be cleaned up. Quell also marks
most of its gameplay entities `ScreenScoped`. This is redundant, but it makes
their scope explicit.

= See also <screens-see-also>

- #l("application-structure") — the screens Quell defines.
- #l("q-os") — terminals and shells, which need to be persistent to survive
  a screen change.
- #l("testing") — screen-lifecycle tests use the same test harness.
