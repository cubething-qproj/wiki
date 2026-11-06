#import "../../template.typ": *
#show: article.with(
  title: [NLP and argumentation],
  summary: [Quell's planned debate mechanic, and the argument analysis and language research behind it.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-03",
)

Quell is meant to let players practise real philosophical debate. That needs
two kinds of groundwork. One is a model of argument structure, detailed enough
for the game to understand what a player has built. The other is a way to tell
what a player's notes are about.

#outdated[NLP was dropped from Quell (2026-11-06): free-text input, runtime parsing, automated argument analysis, the NLP lab's labelling and INCEpTION. Arguments and dialogue are authored by hand. Whether notes are interpreted into concepts is uncertain.]

#wip("debate", "debate-game")[The work so far lives in the labs.]

Start with #l("debate-system"), the intended mechanic and what is still
undecided. #l("argument-maps") describes the reviewed graphs of each text that
debates would be built from, and #l("reading-notes") covers how a player's
highlights and notes would be interpreted.

The other articles explain the argumentation theory and language-processing
techniques this work draws on, grouped by topic below.

= Topics <nlp-topics>

#article-list("nlp", topics: (
  "Debate",
  "Argumentation theory",
  "Understanding text",
  "Generating text",
  "Running models",
  "Measuring results",
))

= Records <nlp-records>

The debate plan's pages, the ATIP algorithm note and the reading-notes design
are drafts in the #link("/documents/nlp.html")[NLP document library].

= See also <nlp-see-also>

- #l("research-labs") — note-lab and the xAIF editor.
