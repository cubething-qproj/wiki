#import "../../template.typ": *
#show: article.with(
  title: [Engine: q_os and libraries],
  summary: [The reusable Bevy crates in `lib/` that Quell and the other games build on.],
)

Quell does not use a separate game engine. It is a Bevy application, and its
reusable infrastructure lives in seven small crates under `lib/`, each
published from its own repository.

Most readers should start with #l("screens"), which every game screen uses,
and whose entity cleanup surprises newcomers. #l("q-os") covers the process,
terminal and shell crates behind Quell's development console, and
#l("testing") covers how all of them are tested.

= The crates at a glance <engine-crates>

#table(
  columns: (auto, auto, 1fr),
  table.header([Crate], [Group], [Purpose]),
  [`q_screens`], [utility], [Screen lifecycle and screen-scoped entities.],
  [`q_cam`], [utility], [The spring arm behind the #l("camera")[tracking camera]; input gating for Bevy's free camera.],
  [`q_test_harness`], [utility], [Headless test runner, steps and synthetic input.],
  [`q_proc`], [q_os], [Processes, programs and typed I/O.],
  [`q_term`], [q_os], [Terminal emulator widget.],
  [`q_shell`], [q_os], [Shell joining processes to a terminal.],
  [`q_query_lang`], [q_os], [Read-only query language over the World.],
)

The utility crates do not depend on one another. Most crates use
`q_test_harness` in their tests. `q_query_lang` does not need it, because it
queries a plain `World` without running an app. Within q_os, `q_shell`
depends on `q_proc` and `q_term`; `q_proc` and `q_term` do not depend on each
other.

= Topics <engine-topics>

#article-list("engine")

= See also <engine-see-also>

- #l("repository-layout") — how the crates are checked out and built together.
