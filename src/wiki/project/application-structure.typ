#import "../../template.typ": *
#show: article.with(
  title: [Quell's application structure],
  summary: [How the Quell binary is assembled from screens, services and shared modules.],
  documents: ("quell-world-generation-design",),
)

The Quell crate (`bin/quell`) is organized around two ideas from its engine
libraries. *Screens* decide what part of the game is running. *Services* provide
the behavior that screens use.#footnote[Checked against `bin/quell/src/` after the Bevy 0.20
migration. The crate's own `docs/architecture.md` describes the same
conventions, but parts of it predate the current layout. It mentions a `mise`
CLI and a main-menu screen, neither of which exists now.]

#contents()

= Start-up <app-startup>

`main.rs` builds a Bevy app from three groups of plugins:

- Bevy's `DefaultPlugins`, with textures set to repeat, because Jackdaw brush
  faces tile their UVs beyond the 0–1 range.
- `AppPlugin`, which installs q_screens' `ScreenPlugin`, all services, and all
  screens, and chooses the initial screen.
- Jackdaw's runtime plugins, which load `.bsn` scenes authored in the
  #link("https://github.com/jbuehler23/jackdaw")[Jackdaw] level editor and
  build Avian colliders from them. The same binary can run windowless when
  Jackdaw asks it for its type schema or embeds it for play-in-editor.

The initial screen is the splash screen unless a screen name is given. In
development builds, `--screen <name>` selects one directly, which is how the
development screens are usually opened.

= Screens <app-screens>

A screen is a Bevy component type that implements q_screens' `Screen` trait. It
registers systems for its loading, ready and update phases. When the game
switches screens, every entity not marked persistent is despawned. See
#l("screens") for the lifecycle.

#table(
  columns: (auto, 1fr),
  table.header([Screen], [What it does now]),
  [`SplashScreen`], [Switches straight to the world screen.],
  [`WorldScreen`],
  [Waits for the player model to load, then spawns the Jackdaw greybox scene
    `scenes/greybox_scene.bsn`. A `PlayerSpawn` placed in that scene spawns
    the player and its camera.],
  [`camera_test` (dev)], [Exercises the tracking and free cameras; see #l("camera").],
  [`greybox_arena` (dev)],
  [Loads the same greybox scene with the player, plus a free camera that Tab
    switches to.],
  [`hex_paths` (dev)],
  [Previews terrain-first trail generation; see #l("terrain-generation").],
)

The world screen loads a test level, not the game world. The `worldgen` service
holds only a placeholder plane, which the world screen does not spawn.

#wip("quell-world-generation-design")[Covers: generated terrain in the world
screen. Generation currently runs only in the `hex_paths` development screen.]

= Services <app-services>

Services are ordinary Bevy plugins under `src/service/`, each of which owns one
concern:

- `input` — the global input context, cursor capture and release, and camera
  input. Bindings use `bevy_enhanced_input` contexts and actions.
- `player` — the kinematic character controller; see #l("player-movement").
- `ui` — the persistent UI camera that draws overlays above the world.
- `worldgen` — the placeholder described above.
- `third_party` — installs external plugins, such as Avian physics, and
  re-exports their preludes.
- `dev` (development builds only) — the egui world inspector and a terminal
  console.

Services do not configure their own system ordering against a screen. A
service exposes its systems, as `player_systems()` does, and each screen that
wants them adds them to its own update schedule. This is why both the world
screen and the greybox arena list the player systems explicitly.

`src/common/` holds code shared by several screens, but not wide enough to be
its own service. At the moment, that is only camera-facing billboards.

= Development builds <app-dev>

The default `dev` feature adds the command-line parser, the egui inspector,
Bevy's free camera, and a console overlay opened with Ctrl+\`. The console is a
q_shell terminal. It provides a `q` command that runs a q_query_lang query
against the live World, for example `q '(@ Name ?Transform)[PlayerController]'`.
See #l("q-os").

Release builds leave these out. The default features also include `jackdaw`,
because the Jackdaw editor builds the game without choosing features.

= File conventions <app-conventions>

Within a module, `data.rs` holds types and `systems.rs` holds systems. A small
`plugin` function, or `plugin.rs`, does the registration. Type definitions come
before free functions. Every crate in the organization follows the same layout.

= See also <app-see-also>

- #l("repository-layout") — where the crate sits in the organization.
- #l("screens") — the screen lifecycle the application is built on.
- #l("player-movement") and #l("camera") — the gameplay services in use today.
