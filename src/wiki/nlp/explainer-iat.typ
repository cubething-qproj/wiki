#import "../../template.typ": *
#show: article.with(
  title: [Inference Anchoring Theory and xAIF],
  summary: [A way of mapping the arguments in a whole text or dialogue, and the JSON format used to store such maps.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Argumentation theory",
  documents: ("pta-document-analysis",),
)

*Inference Anchoring Theory* (IAT) is a framework for mapping arguments as
they actually occur in speech and writing. It was developed at the Centre for
Argument Technology (ARG-tech) in Dundee. IAT's key idea is to keep two
things apart and then connect them: _what people said_, and _what they argued_.
*xAIF* is ARG-tech's JSON format for storing IAT maps. Quell's argument maps
use it, with a few extensions; see #l("argument-maps").

#contents()

= Two layers and the links between them <iat-layers>

An IAT map has a dialogue layer and a logical layer:

- *Locutions* (L-nodes) record exactly what was said, and by whom.
  *Transitions* (TA-nodes) link each locution to the one it responds to or
  follows.
- *Propositions* (I-nodes) record what was asserted, reconstructed as a
  complete statement. They are connected by relations: *inference* (RA,
  "this supports that"), *conflict* (CA, "this opposes that") and
  *rephrase* (MA, "this restates that").

*Illocutionary connections* (YA-nodes) join the two layers. A YA names the
speech act that links a stretch of dialogue to a proposition or relation:
*Asserting* connects a locution to the claim it makes; *Arguing* connects a
transition to an inference; *Disagreeing* connects a transition to a
conflict.

```mermaid
flowchart LR
  L1["L: 'You can't download a car.'"] --> Y1["YA: Asserting"] --> I1["I: Downloading a car is impossible."]
  L2["L: 'Cars are physical.'"] --> Y2["YA: Asserting"] --> I2["I: Cars are physical objects."]
  L1 --> TA["TA"] --> L2
  TA --> Y3["YA: Arguing"] --> RA["RA"]
  I2 --> RA --> I1
```

= Why anchor arguments in dialogue <iat-why>

Ordinary argument maps record only claims and the relations between them.
IAT also records _who_ made the claim and _how_ they made it. That matters
whenever the speech act matters: when someone reports another person's words,
asks a rhetorical question, or concedes a point while disagreeing with it. It
also means every proposition can be traced back to the exact words in the
text. For Quell, that is what would let a reader's highlight be connected to
the statement it expresses.

= xAIF and Quell's additions <iat-xaif>

xAIF stores a map as lists of nodes, edges, speakers and locutions. ARG-tech's
tools, including the OVA map editor, read and write it. Quell's editor keeps
to the format and adds two things:

- a `pta` field on nodes, holding each statement's analysis and each
  inference's #l("explainer-pta")[PTA] type;
- a `lever` role for edges, connecting a statement that states the lever of
  an inference.

The rewording that turns a locution into a canonical proposition is recorded on
the YA between them. Fields the editor does not understand are preserved when
a file is saved.

= See also <iat-see-also>

- #l("argument-maps") — how Quell builds and reviews IAT maps.
- #l("explainer-pta") — the types assigned to inferences.
- #l("explainer-argument-mining") — finding argument structure automatically.

= External links <iat-external>

- #link("https://arg.tech/")[ARG-tech] — the Centre for Argument Technology,
  which develops IAT and its tools.
- #link("https://github.com/arg-tech/xaif")[xAIF] — the format's specification
  and examples.
- #link("https://en.wikipedia.org/wiki/Argument_map")[Argument map] — general
  background.
