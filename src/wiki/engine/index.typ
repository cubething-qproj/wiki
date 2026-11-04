#import "../../template.typ": *
#show: article.with(
  title: [Engine: q_os and libraries],
  summary: [The reusable Bevy crates in `lib/` that Quell and the other games build on.],
)

Quell does not use a separate game engine. It is a Bevy application, and its
reusable infrastructure lives in seven small crates under `lib/`. Each crate is
published from its own repository. This portal explains what each one is for
and how they depend on each other. The API details are in each crate's Rust
documentation.

= Start here <engine-start>

+ #l("screens") — the screen lifecycle every game screen uses, and the entity
  cleanup that surprises newcomers.
+ #l("q-os") — the process, terminal and shell crates behind Quell's
  development console.
+ #l("testing") — how all of these, and the games, are tested.

= The crates at a glance <engine-crates>

#table(
  columns: (auto, auto, 1fr),
  table.header([Crate], [Group], [Purpose]),
  [`q_screens`], [utility], [Screen lifecycle and screen-scoped entities.],
  [`q_cam`], [utility], [Spring-arm follow camera; input gating for Bevy's free camera. See #l("camera").],
  [`q_test_harness`], [utility], [Headless test runner, steps and synthetic input.],
  [`q_proc`], [q_os], [Processes, programs and typed I/O.],
  [`q_term`], [q_os], [Terminal emulator widget.],
  [`q_shell`], [q_os], [Shell joining processes to a terminal.],
  [`q_query_lang`], [q_os], [Read-only query language over the World.],
)

The utility crates do not depend on one another, though most crates use
`q_test_harness` in their tests. `q_query_lang` does not need it, because it
queries a plain `World` without running an app. Within q_os, `q_shell` depends on `q_proc` and
`q_term`. The other two do not know about each other.

= Topics <engine-topics>

#article-list("engine")

= Elsewhere <engine-elsewhere>

- How the crates are checked out and built together: #l("repository-layout").
- Agent skills in `.agents/skills/` (`q-os`, `q-proc`, `q-screens`, and so on)
  are compact working references for each crate. Like the Rust docs, they are
  maintained with the code.
