#import "../../template.typ": *
#show: article.with(
  title: [Repositories and workspace],
  summary: [How the qproj organization nests its repositories and builds them as one Cargo workspace.],
)

Quell is developed inside the *qproj* organization (`cubething-qproj` on
GitHub). Its working tree is an umbrella repository with other repositories
checked out inside it. The game, its engine crates, shared infrastructure and
the labs each keep their own Git history. One Cargo workspace at the root still
builds every Rust crate together.#footnote[Checked against the org root's
`Cargo.toml` and `justfile`, and the Git remotes of each checkout, in November 2026.]

#contents()

= The umbrella and what sits inside it <layout-tree>

```text
cubething-qproj/            org repository: workspace, agent skills, .docs/
├── bin/
│   ├── quell/              the game
│   └── vn-jun-26/          "roach hell", a separate visual novel
├── lib/                    engine crates (see the Engine portal)
│   ├── q_screens/  q_cam/  q_test_harness/
│   └── q_proc/  q_term/  q_shell/  q_query_lang/
├── misc/
│   ├── infra/              shared CI, scripts, Nix flake, crate template
│   ├── labs/               hex-lab, note-lab, xAIF editor (local only)
│   ├── forks/jackdaw/      a checkout of the Jackdaw level editor
│   └── dev/                BSN editor support: tree-sitter grammar, Zed extension
└── .docs/                  designs, plans, issues, handoffs; wiki/ is its own repo
```

The org repository does not track `bin/`, `lib/` or `misc/`. Each directory
beneath them is a separate Git repository with its own branches, pull requests
and CI. This "repo-in-repo" arrangement replaces submodules, which would require
an org commit for every change in every crate. The cost is that the umbrella
cannot record which revision of each crate belongs together.

The three labs have no remote. They are local research repositories, partly
because the language labs work with book excerpts that must not be published.
See #l("research-labs").

= One workspace, many repositories <layout-workspace>

The root `Cargo.toml` declares a workspace whose members are `bin/*` and
`lib/*`; `misc/` is excluded so that checkouts with workspaces of their own
(such as the Jackdaw fork) are left alone. All crates therefore share one
`target/` directory and one set of build profiles.

Crates refer to one another by Git URL. For example, Quell depends on
`q_screens` at `github.com/cubething-qproj/q_screens`. The workspace then
*patches* each of those URLs back to the local `lib/` checkout:

```toml
[patch."https://github.com/cubething-qproj/q_screens"]
q_screens = { path = "lib/q_screens" }
```

So the same manifest means two things. Inside the umbrella, Quell builds
against whatever is in `lib/q_screens` right now. In a crate's own CI, the
dependency resolves to the upstream repository's default branch. A change that
spans crates therefore has to land in dependency order: first `q_proc` or
`q_term`, then `q_shell`, then the games.

Builds, lints and tests are run from the org root with `just check -p <crate>`
and `just test -p <crate>` (Clippy and nextest), so that everything uses the
shared target directory.

= Shared infrastructure <layout-infra>

`misc/infra` holds what the published crates have in common: a crate template,
GitHub Actions workflows, a Python CLI used by the `just` recipes, and a Nix
flake that reproduces CI. Its `downstream-repos.json` lists the repositories
that receive automated "sync CI and shared config" pull requests: Quell and the
seven `lib/` crates. Each crate also pins the toolchain and runs `cargo-deny`.

All the Rust repositories target the same Bevy release, currently 0.20. Bevy
upgrades are done across the organization at once, in dependency order.
#footnote[The 0.20 migration commits appear in each crate's history. Some
README compatibility tables still say 0.19.]

= Where documentation lives <layout-docs>

There are four kinds of documentation, each with its own home:

- *API and developer docs* are Rust doc comments in each crate, plus a few
  Markdown files such as `lib/q_proc/docs/process-lifecycle.md`.
- *Agent skills* in `.agents/skills/` are compact working references for each
  crate and for tools such as Jackdaw. Crate skills are symlinked from the crate's
  own repository.
- *Procedural records* in `.docs/`: designs, plans, issues and handoffs, sorted
  into `done/`, `retired/` and `wont-do/` as they age. Papers in `.docs/reference/`
  are local-only.
- *This wiki*, in `.docs/wiki/`, is a nested repository. It also holds a
  #link("/documents/index.html")[document library] of selected records.

= See also <layout-see-also>

- #l("application-structure") — how the Quell crate is organized internally.
- #l("portal-engine") — what each `lib/` crate is for.
- #l("research-labs") — the local labs under `misc/labs/`.

= External links <layout-external>

- #link("https://doc.rust-lang.org/cargo/reference/overriding-dependencies.html#the-patch-section")[Cargo: the `[patch]` section]
  — how the workspace redirects Git dependencies to local paths.
- #link("https://github.com/casey/just")[just] — the command runner used for
  every build recipe.
