#import "../../template.typ": *
#show: article.with(
  title: [Glossary],
  summary: [Short definitions of terms used across Quell's articles, with links to fuller explanations.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Reference",
)

#contents()

= Argumentation <glossary-argumentation>

/ Canonical statement: a proposition reworded so that the terms it shares
  with another statement are literally the same. See #l("explainer-pta#pta-atip").
/ Character: in debate, a non-player character the player argues with.
/ Form, substance: two of the three properties that determine an argument's
  type in the #l("explainer-pta")[Periodic Table of Arguments]. Form is what the
  premise and conclusion share; substance is what kinds of statement they are.
/ Gold map: a human-reviewed #l("argument-maps")[argument map], used as game
  content and as the standard that automated approaches are scored against.
/ Grounded extension: the arguments that survive a debate under the most
  cautious reading. See #l("explainer-dung").
/ IAT: Inference Anchoring Theory, a way of mapping the arguments in a text or
  dialogue. See #l("explainer-iat").
/ Lever: the usually unstated principle by which a premise supports a
  conclusion, such as cause, example or analogy.
/ Locution, proposition: what was said, and what was asserted by saying it.
/ PTA: the #l("explainer-pta")[Periodic Table of Arguments], a classification
  of 50 argument types.
/ Thinking editor: the planned in-game tool in which players link statements
  into arguments. See #l("debate-system").
/ Tier: one of three increasingly costly ways of interpreting a player's
  notes. See #l("reading-notes#notes-tiers").
/ xAIF: ARG-tech's JSON format for IAT maps, which Quell's maps extend.

= Research method <glossary-method>

These terms appear mostly in the research records.

/ Arm: one way of answering a question, either a rule or a model with a given
  set-up. Arms are compared against each other on the same data.
/ Exemplar: an individual case, inspected before statistics are computed.
/ Oracle: a judgement that rules cannot make, answered by a model with a
  probability.
/ Spike: a small, quick experiment testing whether an approach works at all.

= Procedural generation <glossary-pcg>

/ Layout: the arrangement of landmarks and trails over fixed terrain. See
  #l("trail-layout").
/ Pin: a landmark or trail that regeneration must preserve.
/ Region: the large simulated landscape from which a board is chosen. See
  #l("terrain-generation").
/ Tease: a landmark visible from a viewpoint but deliberately far to walk to.
/ Terrain: the chosen window sampled onto the board's hex mesh.
/ Window: the board-sized part of a region chosen for play.

= Engine and gameplay <glossary-engine>

/ Greybox: a rough test level built from simple shapes, used to try out
  movement and cameras before real art exists.
/ Jackdaw: the brush-based level editor used to author Quell's test levels.
/ Persistent: an entity that survives a change of screen. See #l("screens").
/ Process, program: one running invocation, and the code it runs. See
  #l("q-os").
/ Screen: a self-contained part of the game, with its own lifecycle and
  entities. See #l("screens").
/ Service: a Bevy plugin providing one area of game behavior, used by
  screens. See #l("application-structure").
/ Spring arm: the mechanism that keeps the tracking camera behind the player
  and pulls it in when scenery is in the way.
/ Tracking camera: Quell's third-person gameplay camera. See #l("camera").
