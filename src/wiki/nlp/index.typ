#import "../../template.typ": *
#show: article.with(
  title: [NLP and argumentation],
  summary: [Quell's planned debate mechanic, and the argument analysis and language research behind it.],
)

Quell is meant to let players practise real philosophical debate. That needs
two kinds of groundwork. One is a model of argument structure, detailed enough
for the game to understand what a player has built. The other is a way to tell
what a player's notes are about. This area covers the plan, the research that
supports it, and the techniques that research draws on.

#wip("debate", "debate-game")[The work so far lives in the labs.]

= Start here <nlp-start>

+ #l("debate-system") — the intended mechanic, its constraints, and what is
  still undecided.
+ #l("argument-maps") — the reviewed graphs of each text that debates would be
  built from.
+ #l("reading-notes") — interpreting highlights and free-text notes as
  concepts.

= Argumentation theory <nlp-theory>

- #l("explainer-pta") — classifying an argument by form, substance and lever.
- #l("explainer-iat") — mapping the arguments of a whole text or dialogue.
- #l("explainer-capna") — judging whether an argument is good.
- #l("explainer-dung") and #l("explainer-value-based") — deciding which
  arguments survive a debate.
- #l("explainer-argument-mining") — finding arguments in text automatically.

= Language-processing techniques <nlp-techniques>

- Understanding text: #l("explainer-embeddings"), #l("explainer-cross-encoders"),
  #l("explainer-nli"), #l("explainer-gliner2") and
  #l("explainer-dependency-parsing").
- Generating text with small models: #l("explainer-in-context-learning"),
  #l("explainer-constrained-decoding"), #l("explainer-prompt-caching"),
  #l("explainer-lora") and #l("explainer-quantization").
- Running models in the game: #l("explainer-onnx").
- Measuring results: #l("explainer-stage-wise-evaluation") and
  #l("explainer-calibration").

= All topics <nlp-topics>

#article-list("nlp")

= Records <nlp-records>

The debate plan's pages, the ATIP algorithm note and the reading-notes design
are in the #link("/documents/nlp.html")[NLP document library]. They are drafts.
