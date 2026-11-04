#import "../../template.typ": *
#show: article.with(
  title: [Cameras],
  summary: [The third-person spring-arm camera, the developer free camera, and which of them owns input.],
)

Quell has two gameplay cameras. The *tracking camera* is a third-person orbit
camera on a spring arm. It follows the player and pulls in when scenery would
come between them. The *free camera* is Bevy's developer fly camera, available
only in development builds. One gameplay camera renders and receives input at
a time. A separate UI camera always draws overlays on top.#footnote[Checked
against `lib/q_cam/src/` and `bin/quell/src/service/input/camera/`. The approved
camera design (2026-09-24) is `.docs/designs/done/quell-camera-design.md`.]

#contents()

= The spring arm <camera-spring-arm>

The spring arm lives in the `q_cam` crate, so it does not depend on Quell's
types. Each frame, after transforms have propagated, it places the camera
behind a pivot point on its target:

+ Find the pivot: the target's position plus a fixed offset.
+ Extend the arm backwards from the pivot, along the camera's own rotation, to
  its desired length.
+ Sweep a small sphere along the arm. If it hits scenery, place the camera just
  short of the hit.

The arm sets only the camera's position. Its rotation comes from orbit input:
mouse motion or the right stick change yaw and pitch, and pitch is clamped to a
narrow range. The mouse wheel changes the field of view; it does not change
the arm's length. Nothing is smoothed or stored between frames. When an
obstruction clears, the camera returns to full length at once.

The collision sweep ignores the camera, the target and the target's colliders,
sensors, and anything on the layers the game excludes. Quell excludes the
player's collision layer. The sweep keeps the probe sphere clear of geometry,
but this does not guarantee that the camera's near plane is clear as well.

= Which camera is in charge <camera-ownership>

The `is_active` flag on Bevy's `Camera` is the only record of which gameplay
camera is selected. Nothing else stores the mode separately. Input is allowed
or refused based on that selection, together with window focus and cursor
capture:

- Orbit and zoom need the tracking camera to be selected, the window focused
  and the cursor captured. A click captures the cursor. Escape releases it,
  and a second Escape quits.
- Player movement needs the tracking camera and focus, but not capture. See
  #l("player-movement").
- The free camera's input gate keeps Bevy's controller disabled until it is
  armed. That happens only once the capture buttons and Escape have been
  released, so a click or key press carried over from a reset does not take
  control.

In the world screen and the greybox arena, the player's tracking camera is the
default, and Tab switches to the free camera. The `camera_test` screen keeps
both cameras alive. Each keeps its own view when Tab switches between them, and
help text describes the active mode.

= Arrangement <camera-arrangement>

Gameplay cameras are root entities without children. The spring arm writes the
camera's global transform directly, which only works if no hierarchy sits
above or below it. The player is the camera's *target*, not its parent. The
camera is linked to the player by a relationship, so it is despawned with the
player.

The arm's length, probe radius and offset are reflected fields that can be
edited live. Zoom speed lives in a shared settings resource.

#undecided[The design gives the spring-arm values (10 m arm, 0.3 m probe) as
initial tuning. Whether they suit the game has not been established in
playtesting.]

= See also <camera-see-also>

- #l("player-movement") — movement relative to the tracking camera's yaw.
- #l("testing") — camera tests drive mouse and keyboard input through selected schedules.
- #l("portal-engine") — `q_cam` among the other engine crates.

= External links <camera-external>

- #link("https://dev.epicgames.com/documentation/en-us/unreal-engine/using-spring-arm-components-in-unreal-engine")[Unreal Engine: spring arm components]
  — the familiar model this camera follows.
