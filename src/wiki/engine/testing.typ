#import "../../template.typ": *
#show: article.with(
  title: [Testing Bevy code],
  summary: [How qproj tests games and crates with q_test_harness: full-app runs and selected-schedule steps.],
)

Quell and most of the `lib/` crates are tested through `q_test_harness`, a
small shared crate for running Bevy apps under `cargo nextest`. It supports
two kinds of test. A
*full-app* test runs an ordinary app loop until the test writes `AppExit`. A
*selected-schedule* test feeds synthetic input and advances only the schedules
it names. Choosing between them is a decision about what the test is meant to
show.#footnote[The harness's API is documented in its README, its Rust docs
and the `q-test-harness` agent skill.]

#contents()

= Full-app tests <testing-full-app>

`TestRunnerPlugin` sets up a headless app with logging and log capture. It
uses a single-threaded executor and a timeout that fails a stalled test. A test
is written as numbered *steps*, each a system that runs while the step is
current. Steps can wait for a condition, make assertions, and then advance to
the next step. Assertion helpers end the test with an error exit, and finder
helpers look up entities by name.

Full-app tests are the right choice when the question involves scheduling or
lifecycle. Examples include screen transitions, process exit, or whether
output reaches a terminal within the same frame. The q_screens, q_proc, q_term
and q_shell test suites mostly work this way.

= Selected-schedule tests <testing-selected>

`InputTestPlugin`, together with the `AppExt` trait, lets a test press keys,
move the mouse, and then `step` the app through chosen schedules with an
explicit time delta. This suits precise mechanics, such as how a camera
responds to one frame of mouse motion. Quell's camera, free-camera and player
movement tests use this approach.

A passing selected-schedule test says nothing about the schedules it left out.
If a behavior depends on ordering across `PreUpdate`, `FixedUpdate` and
`PostUpdate`, it needs a full-app test as well.

= Conventions <testing-conventions>

- *Fixtures stay local.* A test module with repeated set-up defines a small
  `Fixture` that owns the `App` and the relevant entity IDs, with methods for
  that scenario's actions and assertions. Quell's `camera_test` screen has an
  example. Reusable machinery belongs in the harness, which must not depend on
  any game's types.
- *Unit tests sit in `src/`; fixture-based integration tests sit in `tests/`.*
  Quell's player-movement integration test is an example of the latter.
- *Test behavior, not constants.* Tests should not assert tuning values or
  incidental facts, such as the order of screens. A test that would belong in
  an upstream crate should be reported there.

The harness does not render. Headless rendering, screenshots, scene snapshots
and replay are listed in its README as stretch goals.

= See also <testing-see-also>

- #l("screens") — the lifecycle that many full-app tests exercise.
- #l("camera") and #l("player-movement") — systems tested by selected-schedule steps.

= External links <testing-external>

- #link("https://nexte.st")[cargo-nextest] — the test runner used across the
  workspace.
