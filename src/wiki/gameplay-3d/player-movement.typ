#import "../../template.typ": *
#show: article.with(
  title: [Player movement],
  summary: [Quell's kinematic character controller: how the player walks, meets slopes and stays on the ground.],
)

The player character is a kinematic capsule moved by Quell's own small
controller, built on Avian physics' `MoveAndSlide`. Physics forces never push
the player. Each fixed step, the controller decides where to move and lets
Avian slide that motion along whatever it touches. This article describes the
behavior implemented now. The controller is intentionally minimal, and several
common features are absent by design.#footnote[Checked against
`bin/quell/src/service/player/`, especially the module documentation of
`movement.rs`, which states the movement policy.]

#contents()

= From input to motion <movement-pipeline>

```mermaid
flowchart LR
  IN["Move action<br/>(WASD / left stick)"] --> PC["PlayerController<br/>last input"]
  CAM["tracking camera yaw"] --> UC
  PC --> UC["update_controller<br/>(screen Update)"]
  UC --> PM["PlayerMotor<br/>desired velocity, facing"]
  PM --> MV["move_player<br/>(FixedUpdate)"]
  MV --> AV["Avian move-and-slide"]
```

Input is read through `bevy_enhanced_input` and smoothed, so analog sticks keep
their magnitude. Every frame, the movement direction is rotated by the tracking
camera's yaw, so "forward" means away from the camera. The result is written to
`PlayerMotor` as a desired velocity and facing. The fixed-step system then
moves the body and turns it toward that facing at a limited rate.

Movement only happens while the tracking camera is the active camera and the
window has focus. Switching to the free camera or leaving the window stops the
player. Input released in the meantime does not resume when control returns.

The update system belongs to the screen, so a screen with a player must
schedule it, while the fixed-step movement is installed globally. See
#l("application-structure#app-services").

= Ground, slopes and steps <movement-policy>

- *Grounding.* Before each move, the capsule is cast a short distance downward.
  If that finds a walkable surface, the player is grounded: gravity is skipped,
  and the player is snapped back onto the ground after moving. This is also
  how the player steps down off small ledges.
- *Slopes.* A surface steeper than the maximum walkable slope (45° by default)
  acts like a wall for horizontal movement. The player cannot climb it, but
  falls along it.
- *Steps.* There is no explicit step-up. The capsule's rounded base rides over
  only very small ledges, about 0.15 m with the default settings.
- *Other bodies.* Moving platforms are not supported, and dynamic bodies do not
  push the player.

Sliding down a steep slope is slow and depends on the timestep, because only
vertical velocity carries over between ticks. This is a known limitation of
the current policy.

= Spawning <movement-spawn>

Levels place a `PlayerSpawn` marker in a Jackdaw scene. When a spawn point is
inserted, Quell spawns a player there if none exists yet. The player starts
resting on the ground, because move-and-slide cannot resolve a capsule that
starts deep inside geometry. Reloading the scene re-inserts the marker without
creating a duplicate player.

The player entity receives its capsule collider, its model and its tracking
camera when it is added. The camera is linked to the player by a relationship,
so the two are despawned together. The player's collider is on its own
collision layer so that the camera's obstruction test can ignore it. See
#l("camera").

= Tuning <movement-tuning>

Speed, capsule size, maximum slope, ground-snap distance and turn rate are
fields of the `PlayerSettings` resource. They can be changed at runtime in the
inspector. Capsule dimensions apply only to players spawned afterwards.

= Why a local controller <movement-why>

The controller replaced an earlier integration of the Tnua controller library.
Investigation showed that the earlier controller had never moved the player,
so there was no established feel to preserve. A Quake-style controller library
was rejected for a third-person game, because its movement model, input
normalization and camera assumptions would have needed to be worked around.
#footnote[Approved controller design, 2026-09-27:
`.docs/designs/done/quell-kinematic-controller-design.md`; Quell issue #13.]
The policy above is the deliberately small result. Features such as stair
stepping can be added if the game needs them.

#undecided[Whether Quell needs stair stepping. The controller design leaves it
for later and suggests porting the step and ground-snap routines from
`bevy_ahoy`, with attribution, rather than taking on the dependency.]

= See also <movement-see-also>

- #l("camera") — the tracking camera that defines the direction of movement.
- #l("testing#testing-selected") — how the movement tests drive input.

= External links <movement-external>

- #link("https://docs.rs/avian3d/latest/avian3d/")[Avian 3D] — the physics
  engine, including its move-and-slide utilities.
