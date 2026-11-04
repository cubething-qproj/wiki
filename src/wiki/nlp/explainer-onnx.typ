#import "../../template.typ": *
#show: article.with(
  title: [ONNX and ort],
  summary: [A portable format for trained models, and the Rust library that lets the game run them without Python.],
  documents: ("debate-pipeline", "quell-reading-notes-design"),
)

*ONNX* (Open Neural Network Exchange) is a portable file format for trained
machine-learning models. A model trained in Python with PyTorch, for
example, can be exported to ONNX. *ONNX Runtime* then runs it efficiently on
many platforms and kinds of hardware. *`ort`* is ONNX Runtime's Rust binding.

= In Quell <onnx-quell>

The labs prototype in Python, but the game is written in Rust. Exporting a
lab's models to ONNX would let Quell run exactly the model the lab measured
through `ort`, with no Python at runtime. This is the planned path for
non-generative models such as #l("explainer-embeddings")[embedding],
#l("explainer-nli")[NLI] and #l("explainer-gliner2")[GLiNER] models.
Generative models would use #l("explainer-quantization")[llama.cpp] instead.

= External links <onnx-external>

- #link("https://onnx.ai/")[ONNX] — the format.
- #link("https://onnxruntime.ai/")[ONNX Runtime] — the runtime.
- #link("https://docs.rs/ort")[`ort`] — the Rust binding.
