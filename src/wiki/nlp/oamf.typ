#import "../../template.typ": *
#show: article.with(
  title: [oAMF],
  summary: [ARG-tech's open framework for chaining argument-mining modules into pipelines, and where it could fit Quell's argument maps.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Argumentation theory",
  documents: ("debate-spike", "debate-pipeline"),
)

The *Open Argument Mining Framework* (oAMF) is a toolkit from the Centre for
Argument Technology (ARG-tech) at the University of Dundee. It splits
#l("explainer-argument-mining")[argument mining] into small steps, such as
segmenting text, extracting propositions and finding the relations between
them, and lets any module for a step be swapped for another. Every module reads
and writes #l("explainer-iat")[xAIF], the format Quell's argument maps use.

#contents()

= How it works <oamf-design>

Each module is a small web service in a Docker container. It receives an xAIF
document, adds its own layer of analysis and returns the document. A pipeline
is a graph of modules: a turn separator feeds a segmenter, the segmenter feeds
a propositionaliser, and so on. Pipelines can be built with the Python library
(`oamf` on PyPI), in a drag-and-drop editor based on n8n, or through a web
interface. Modules are either deployed locally from their GitHub repositories
or called on ARG-tech's servers. New modules start from a template project,
AMF_NOOP.#footnote[Gemechu et al. 2025a, sections 3.1–3.3 and appendix A.]

Fixing the format and keeping the modules independent is the point of the
design. One step can be replaced or compared without touching the rest of the
pipeline, and modules built on different theories of argument can still be
combined.#footnote[Gemechu et al. 2025b, section 3.]

= Modules <oamf-modules>

The framework launched with seventeen modules:#footnote[Gemechu et al. 2025a,
  section 3.4 and table 2. The papers don't say what most modules were trained
  on; each module's `metadata.yaml` has a field for it.]

#table(
  columns: (auto, auto, 1fr),
  table.header([Step], [Modules], [Approach]),
  [Turns], [DTSG], [Splits a transcript into speakers' turns.],
  [Segments],
  [DSG, TARGER, DSS],
  [Divide text into locutions. DSS prompts DeepSeek-R1 1.5B with a few
    examples.],

  [Anaphora], [DARJ], [Resolves pronouns in locutions.],
  [Propositions],
  [SPG, CPJ],
  [Extract the proposition each locution asserts. CPJ is a cascade that
    resolves anaphora, checks for reported speech and reconstructs the
    subject.],

  [Relations],
  [DAMG, DTERG, SARIM, ARIR, TARGER-AM, DRIG, DSRM],
  [Find support, conflict and rephrase between propositions. ARIR is a
    fine-tuned RoBERTa classifier over pairs (none, inference, conflict,
    rephrase), DRIG a fine-tuned DialoGPT, DSRM DeepSeek-R1 1.5B prompted
    with examples.],

  [Schemes],
  [WSCR, PDSCZ],
  [Label inferences with Walton's schemes, or with pragma-dialectics'
    comparison, symptomatic and causal argumentation.],

  [Statement type],
  [PTCR],
  [A fine-tuned RoBERTa classifier: fact, value or policy.],
)

Three tools sit alongside the modules. CASS compares two xAIF maps of the same
text and reports macro F1, accuracy, kappa, U-alpha and text similarity. WSTT
transcribes audio with Whisper, and SV draws a map as SVG.

= Performance <oamf-performance>

ARG-tech evaluated three pipelines on a corpus of student essays (AAEC) that
none of the modules were trained on. The best found argument components with
an F1 of 56.32 and relations with 32.65. The best end-to-end systems they were
compared with, trained on the same corpus, reached 76.55 and 54.66. On the
harder cross-corpus relation task, one oAMF pipeline scored 47.37, ahead of
the previous best of 42.00.#footnote[Gemechu et al. 2025a, section 5 and
  table 1.] Finding relations remains the weak step, as it is across the
field.

The modules differ greatly in speed. For a single relation-identification
sample, DSRM, the DeepSeek module, took 19.461 seconds, and DTERG, which is
BERT-based, took 0.345 seconds.#footnote[Gemechu et al. 2025a, section 5.]

= In Quell <oamf-quell>

oAMF covers the structural layer of Quell's
#l("argument-maps")[argument maps]: locutions, propositions, and support,
conflict and rephrase relations. PTCR's three classes are the same fact, value
and policy distinction that the #l("explainer-pta")[Periodic Table of
  Arguments] uses for statement types. Nothing in oAMF produces the PTA layer:
canonical subjects and predicates, scope, levers, second-order statements or
implicit premises. Its scheme classifiers use other taxonomies, which don't map
onto PTA levers.

That makes it a candidate for several roles. CASS could score the
spike's output against the gold maps.#footnote[#doc("debate-spike")[The
    spike] plans to compare exemplars with gold before computing statistics.] An
off-the-shelf pipeline run over the gold passages would show how much of the
structure can be had without new work. The framework's design matches the
#doc("debate-pipeline")[oracle pipeline]: one small model per question, joined
by a shared format. Its timings support using fine-tuned encoders rather than
small generative models where the game needs answers in real time.

The modules themselves can't ship in the game, since they are Python web
services. A module's model would have to be taken out and run in-process, for
example through #l("explainer-onnx")[ONNX].

#undecided[Whether oAMF becomes part of the pipeline, as an evaluator, a
  baseline, a source of models, or not at all.]

#gotcha[The licence is stated three ways: LGPLv3 in the ACL paper, GPL-3.0 in
  the repository's metadata and Apache 2.0 in its README. Check each module's
  licence before using it in anything that ships.]

#gotcha[ARG-tech's hosted modules receive the text they analyse. The lab's
  corpus passages are excerpts of published books, so they must go only
  through locally deployed modules.]

= See also <oamf-see-also>

- #l("explainer-argument-mining") — the research field oAMF serves.
- #l("explainer-iat") — the dialogue model behind xAIF.
- #l("explainer-stage-wise-evaluation") — how candidate approaches are to be
  scored.

= References <oamf-references>

- Gemechu, D., Ruiz-Dolz, R., Gorska, K., Moslemnejad, S., Maguire, E.,
  Zografistou, D., Jo, Y., Lawrence, J., & Reed, C. (2025a). The Open Argument
  Mining Framework. In _Proceedings of the 63rd Annual Meeting of the ACL
  (Volume 3: System Demonstrations)_, 318–328.
  #link("https://aclanthology.org/2025.acl-demo.31/")[ACL Anthology].
- Gemechu, D., Ruiz-Dolz, R., Lawrence, J., & Reed, C. (2025b). Practical
  Solutions to Practical Problems in Developing Argument Mining Systems. In
  _Proceedings of the 12th Argument Mining Workshop_, 100–106.
  #link("https://aclanthology.org/2025.argmining-1.9/")[ACL Anthology].

= External links <oamf-external>

- #link("https://github.com/arg-tech/oAMF")[oAMF on GitHub] — module list and
  documentation.
- #link("https://pypi.org/project/oamf/")[oamf on PyPI].
- #link("https://oamf.arg.tech")[oAMF web interface].
