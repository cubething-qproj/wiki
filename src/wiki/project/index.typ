#import "../../template.typ": *
#show: article.with(
  title: [Project overview],
  summary: [Where Quell's code, libraries, experiments and documentation live, and how they relate.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-03",
)

Quell is a Bevy game developed alongside a family of small engine libraries and
a set of research labs.

#l("repository-layout") explains which repositories exist, why they sit inside
one another, and how one Cargo workspace builds them all.
#l("application-structure") shows how the game itself is put together from
screens and services. #l("research-labs") covers the Python and web labs where
generators and language tools are prototyped before anything reaches Rust.
Terms that recur across the articles are defined in the #l("glossary").

= Topics <project-topics>

#article-list("project", topics: ("Organization", "The game", "Reference"))

= Records <project-records>

Proposals, plans and experiment reports are in the
#link("/documents/index.html")[document library].

= See also <project-see-also>

- #l("portal-engine") — the `lib/` crates: screens, the q_os process and shell
  stack, and the test harness.
- #l("portal-gameplay-3d") — the player character and cameras in the 3D world.
- #l("portal-pcg") — terrain and trail generation.
- #l("portal-nlp") — the planned debate mechanic and the argumentation research
  behind it.
