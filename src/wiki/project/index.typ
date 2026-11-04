#import "../../template.typ": *
#show: article.with(
  title: [Project overview],
  summary: [Where Quell's code, libraries, experiments and documentation live, and how they relate.],
)

Quell is a Bevy game developed alongside a family of small engine libraries and
a set of research labs. This portal gives the shape of the whole project: where
each part lives, and how the parts depend on each other.

= Start here <project-start>

+ #l("repository-layout") explains the organization: which repositories exist,
  why they sit inside one another, and how one Cargo workspace builds them all.
+ #l("application-structure") explains how the Quell binary itself is put
  together from screens and services.
+ #l("research-labs") explains the Python and web labs where generators and
  language tools are prototyped before anything reaches Rust.
+ #l("glossary") defines terms that recur across the articles.

= Where to go next <project-next>

Each area of the wiki has its own portal:

- #l("portal-engine") — the `lib/` crates: screens, the q_os process and shell
  stack, and the test harness.
- #l("portal-gameplay-3d") — the player character and cameras in the 3D world.
- #l("portal-pcg") — terrain and trail generation.
- #l("portal-nlp") — the planned debate mechanic and the argumentation research
  behind it.

= Topics <project-topics>

#article-list("project")

= Records <project-records>

Proposals, plans and experiment reports are kept in the
#link("/documents/index.html")[document library]. Each crate's API is
documented with its code.
