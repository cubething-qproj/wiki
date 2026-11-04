#import "../../template.typ": *
#show: wiki-page.with(
  title: [Open questions],
  status: "draft",
  summary: [Questions without answers yet.],
)

Questions with no answer yet. Each links to where it matters.

#table(
  columns: (1fr, auto),
  table.header([question], [page]),
  [Parse at runtime, or only while authoring?], [#l("debate-spike")[spike]],
  [What's the latency budget for a runtime parse, on what target CPU?],
  [#l("debate-arms")[arms]],

  [Free-text input or the thinking editor (or both)?],
  [#l("debate-game")[game]],

  [oAMF: what does it cover, and can it run locally?],
  [#l("explainer-argument-mining")[argument mining]],

  [How is a debate won? CAPNA, Dung, value-based frameworks.],
  [#l("debate-evaluation")[evaluation]],

  [How many gold maps before scores mean anything?], [#l("debate-gold")[gold]],
  [INCEpTION or the xAIF editor as the annotation tool? All real annotation
    so far has been in the editor.],
  [#l("debate-gold")[gold]],

  [Is the PTA's 50 types too much to teach? The editor could show lever
    families and keep the full code internal.],
  [#l("debate-game")[game]],

  [How does the game stop brute-force submissions?], [#l("debate-game")[game]],
  [Shipping real texts: public-domain translations or permission, per
    text.],
  [—],

  [Three copies of the rules (TS, Python, Rust): a conformance suite, or one
    Rust core compiled to WASM?],
  [#l("debate-phases")[phases]],

  [Reported speech: do reported locutions sit in the reporter's TA chain?
    (open in `judgement-calls.md`)],
  [#l("explainer-iat")[IAT]],

  [Dialogue tool: Yarn via `bevy_yarnspinner`, not yet evaluated.],
  [#l("debate-game")[game]],
)
