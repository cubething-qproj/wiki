#import "../_template.typ": *
#show: wiki-page.with(
  title: [IAT and xAIF],
  status: "current",
  summary: [How a whole text or dialogue is mapped; our file format.],
)

*Inference Anchoring Theory* maps a text or dialogue in layers:

- *locutions* (L): exactly what was said, and by whom. *Transitions*
  (TA) link one locution to the next.
- *propositions* (I): what was asserted, reconstructed. They're linked
  by inference (RA), conflict (CA) and rephrase (MA).
- *illocutionary connections* (YA), such as Asserting or Arguing,
  anchor propositions and relations in the locutions.

*xAIF* is ARG-tech's JSON format for IAT graphs. Our editor adds a
`pta` field to nodes and a `lever` edge role. ATIP's reformulation lives
on the YA (L → YA → I).

See the `xaif-iat` skill and `misc/labs/xAIF/README.md`.
