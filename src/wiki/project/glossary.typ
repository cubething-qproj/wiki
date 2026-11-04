#import "../../template.typ": *
#show: article.with(
  title: [Glossary],
  summary: [Short definitions of terms used across Quell's articles, with links to fuller explanations.],
)

Short definitions of terms that recur across these articles. Each links to a
fuller explanation where one exists.

#contents()

= Argumentation <glossary-argumentation>

/ Canonical statement: a proposition reworded so that the terms it shares
  with another statement are literally the same. See #l("explainer-pta#pta-atip").
/ Connector: one argument in a map, an inference (RA) with its premise,
  conclusion and optional lever statement.
/ Form, substance, lever: the three properties that determine an argument's
  type in the #l("explainer-pta")[Periodic Table of Arguments].
/ Gold map: a human-reviewed #l("argument-maps")[argument map], used as
  content and as the standard that automated approaches are scored against.
/ Locution, proposition: what was said, and what was asserted by saying it.
  See #l("explainer-iat").
/ Grounded extension: the arguments that survive a debate under the most
  cautious reading. See #l("explainer-dung").

= Research method <glossary-method>

/ Arm: one way of answering a question, either a rule or a model with a given
  set-up. Arms are compared against each other on the same data.
/ Oracle: a judgement that rules cannot make, answered by a model with a
  probability.
/ Exemplar: an individual case, inspected before statistics are computed.
/ Spike: a small, quick experiment testing whether an approach works at all.

= Procedural generation <glossary-pcg>

/ Region, terrain, window: the large simulated landscape, and the board-sized
  part of it chosen for play. See #l("terrain-generation").
/ Layout: the arrangement of landmarks and trails over fixed terrain. See
  #l("trail-layout").
/ Pin: a landmark or trail that regeneration must preserve.
/ Tease: a landmark visible from a viewpoint but deliberately far to walk to.

= Engine <glossary-engine>

/ Screen: a self-contained part of the game, with its own lifecycle and
  entities. See #l("screens").
/ Persistent: an entity that survives a change of screen.
/ Process, program: one running invocation, and the code it runs. See
  #l("q-os").
/ Spring arm: the third-person camera rig that pulls in when scenery is in
  the way. See #l("camera").
