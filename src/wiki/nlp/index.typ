#import "../../template.typ": *
#show: article.with(
  title: [NLP and argumentation],
  summary: [Quell's planned debate mechanic, and the argument analysis and language research behind it.],
)

Quell is meant to let players practise real philosophical debate. That needs
two kinds of groundwork. One is a model of argument structure, detailed enough
for the game to understand what a player has built. The other is a way to tell
what a player's notes are about.

#wip("debate", "debate-game")[The work so far lives in the labs.]

Start with #l("debate-system"), the intended mechanic and what is still
undecided. #l("argument-maps") describes the reviewed graphs of each text that
debates would be built from, and #l("reading-notes") covers how a player's
highlights and notes would be interpreted.

The remaining articles explain the ideas this work draws on. The
argumentation theory begins with the #l("explainer-pta") and
#l("explainer-iat"). For judging arguments and debates, see #l("explainer-capna"),
#l("explainer-dung") and #l("explainer-value-based"). The language-processing
techniques start from #l("explainer-embeddings") for understanding text and
#l("explainer-in-context-learning") for generating it, with
#l("explainer-stage-wise-evaluation") for measuring the results.

= Topics <nlp-topics>

#article-list("nlp")

= Records <nlp-records>

The debate plan's pages, the ATIP algorithm note and the reading-notes design
are drafts in the #link("/documents/nlp.html")[NLP document library].

= See also <nlp-see-also>

- #l("research-labs") — note-lab and the xAIF editor.
