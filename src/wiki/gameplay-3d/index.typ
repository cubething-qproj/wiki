#import "../../template.typ": *
#show: article.with(
  title: [Gameplay: physics and 3D world],
  summary: [The player character, cameras and test levels in Quell's 3D world.],
)

Quell's playable 3D world is still at the greybox stage. A player character
walks around a level authored in Jackdaw, followed by a third-person camera.
This portal covers those foundations. Exploration content such as the
generated trail networks is covered by #l("portal-pcg").

= Start here <gameplay-start>

+ #l("player-movement") — how the kinematic controller walks, handles slopes
  and spawns.
+ #l("camera") — the spring-arm tracking camera, the free camera, and how
  they share input.

= Topics <gameplay-topics>

#article-list("gameplay-3d")

= Levels <gameplay-levels>

Test levels are `.bsn` scenes made in the Jackdaw editor, which builds levels
from brushes. The world screen and the `greybox_arena` development screen both
load `scenes/greybox_scene.bsn`. A level decides where the player appears by
containing a `PlayerSpawn`. Jackdaw can also run the game inside the editor;
see #l("application-structure#app-startup").

The greybox scene is a test level for controller and camera work, not the
game's world. In the world-generation proposal, the world screen would play
generated levels instead, and the greybox scene would move to its own screen.

#wip("quell-world-generation-design")
