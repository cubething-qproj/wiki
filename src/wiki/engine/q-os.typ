#import "../../template.typ": *
#show: article.with(
  title: [q_os: processes, terminal and shell],
  summary: [A set of crates that brings a small operating-system model to Bevy: processes, typed I/O, a terminal and a shell.],
)

*q_os* is the name for four of qproj's crates that borrow their ideas from an
operating system. In Quell, they power the development console. Work that
spans many frames becomes a *process*. Processes
exchange typed messages through file descriptors. A *terminal emulator*
displays text, and a *shell* lets a person launch processes by typing commands.
The aim is a familiar way to switch pieces of behavior on and off in a running
Bevy app, and eventually a scripting language for live editing.#footnote[The
motivation is set out in `.docs/designs/q_os design.md`. That file is a short
design note, not a specification.]

The crates are optional dependencies of Quell, enabled by its `dev` feature.

#contents()

= The crates <qos-crates>

```mermaid
flowchart TB
  SHELL["q_shell<br/>jobs, commands, keyboard"] --> PROC["q_proc<br/>processes and I/O"]
  SHELL --> TERM["q_term<br/>terminal emulator"]
  QUERY["q_query_lang<br/>World queries"] -.->|"exposed as a command"| SHELL
  LANG["qscript (planned)"] -.->|"would parse commands for"| SHELL
```

#table(
  columns: (auto, 1fr),
  table.header([Crate], [Responsibility]),
  [`q_proc`], [Processes, programs, file descriptors, I/O routing, pipes and tees.],
  [`q_term`],
  [A `bevy_ui` terminal widget with an ANSI/VT parser. It knows nothing about
    processes.],
  [`q_shell`],
  [Connects the two. It provides shells, command lookup, jobs and foreground
    control, and a pluggable command language.],
  [`q_query_lang`],
  [A read-only, string-based query language over the World. It does not
    depend on the other crates; a shell can expose it as a command.],
)

The separation is deliberate. q_term can render any byte stream, and q_proc can
route output to any endpoint. Only q_shell knows that a terminal is attached to
a process.

= Processes and programs <qos-processes>

A *program* is a component type with a `ProgramLabel`, plus ordinary Bevy
systems that query for entities carrying that component. A *process* is one
entity holding a `Process` component, the record of one invocation with its
arguments and environment. Spawning a process inserts the program's marker, so
the program's systems pick it up on the next run. One system advances every
running invocation of its program.

A process ends when it exits with a code or when it is despawned. In either
case, a single `ProcessExited` event is triggered. Earlier designs dispatched a
hidden system per process. The current model runs programs as ordinary systems
in the app's normal schedules.#footnote[The accepted direction is recorded in
the "ordinary-system job model" design under `.docs/handoffs/done/`. The
lifecycle rules are documented in `lib/q_proc/docs/process-lifecycle.md`.]

A process's file descriptors point at *endpoints*. These can be a terminal,
another process's input, a pipe or a tee. Writes are typed. A byte stream is
one kind of message among others, so programs can pass structured values
without serializing them to text.

= Terminal and shell <qos-shell>

q_term implements a terminal in `bevy_ui`. It parses a subset of ANSI and VT
escape sequences, keeps a scrollback, and applies a line discipline to keyboard
input. Raw mode, multiplexing and full-screen TUIs are not supported.

q_shell turns registered programs into commands. Registering a program with q_proc
makes its name available to every shell. The bundled language parses one
command per line, with quoting and escapes. In it, `|`, `>` and `;` are just
arguments, not operators. Another language can be plugged in, provided it
produces the same command representation (`ShellIr`) for the interpreter.

= Querying the World <qos-query>

q_query_lang reads ECS data from strings that mirror Bevy's `Query<D, F>`
types. A query is a pipeline of stages: `(Name ?Health)[Enemy !Dead]` reads
names and optional health from living enemies, and `#Floor | Children[..]`
follows a relationship from a named entity. Execution returns a snapshot of
rows; it never changes the World. Quell's console exposes it as the `q` command.

= Timing within a frame <qos-frame>

q_proc runs in each of Bevy's standard update schedules, and the shell adds its
own ordering within `Update`. Two consequences matter in practice:

- *Input arrives one frame late.* Keyboard input that reaches a process's stdin
  during `Update` is queued at the start of the next frame.
- *Output appears in the same frame*, when it is written in `Update`.

The detailed ordering is documented with the crates and in the `q-os` agent skill.

= Limits and plans <qos-limits>

- *Signals exist only as types.* q_shell sends a hang-up signal when its
  terminal closes, but nothing yet receives signals. Per-process signal
  overrides are not used.
- *There is no filesystem.* A path-based projection of the ECS (`q_fs`) was
  considered and set aside. The q_os note suggests that Bevy's asset system
  already covers host files, and the qscript design lists a virtual
  filesystem as a non-goal.

#undecided[What the planned `q_coreutils` crate should contain. The q_os design
note lists it with "contents TBD".]

== qscript <qos-qscript>

The planned shell language, qscript (`q_shell_lang`), is an imperative
language with values, closures and sequencing that spans frames. Its design
direction is in `.docs/designs/q_shell_lang-design.md`.

#wip[Its syntax is not specified.]

= See also <qos-see-also>

- #l("application-structure") — where the console sits in Quell.
- #l("screens") — why terminals and shells must be marked persistent if they
  should survive a screen change.
- #l("portal-engine") — the other engine crates.

= External links <qos-external>

- #link("https://vt100.net/docs/vt100-ug/")[VT100 user guide] — background on
  the terminal model q_term approximates.
- #link("https://docs.rs/bevy/latest/bevy/ecs/system/struct.Query.html")[Bevy `Query`]
  — the type syntax that q_query_lang mirrors.
