#import "../_template.typ": *
#show: wiki-page.with(
  title: [ONNX and ort],
  status: "current",
  summary: [A portable model format the game can run without Python.],
)

*ONNX* is a portable file format for trained models. ONNX Runtime runs
it on many platforms; *`ort`* is its Rust binding. Exporting a lab model
to ONNX means the game runs exactly the model the lab measured.
Generative models use llama.cpp instead.
