#import "../../template.typ": *
#show: article.with(
  title: [Quantization and llama.cpp],
  summary: [Storing a model's weights in fewer bits so that it fits in memory and runs on a CPU.],
  documents: ("debate-spike",),
)

A neural network's weights are usually stored as 16-bit numbers.
*Quantization* stores them with fewer bits, often about four per weight. That
cuts the model's size, and the memory traffic needed to run it, by roughly
four times, at a small cost in quality. A model with 3 billion parameters
shrinks from about 6 GB to about 2 GB. Since running such a model on a CPU is
limited mostly by memory bandwidth, it also becomes faster.

*llama.cpp* is a C++ runtime for running quantized language models on
ordinary hardware. It runs on a CPU, and can optionally offload some layers to
a GPU. Its model format is *GGUF*, and its `llama-server` program exposes a
model over HTTP.

= In Quell <quantization-quell>

The game must run on machines with modest GPUs, so any generative model it
uses has to be small and quantized. The planned spike tests models of about
1.5–3 billion parameters through `llama-server`. Smaller and larger sizes are
later comparisons.

= See also <quantization-see-also>

- #l("explainer-constrained-decoding") — llama.cpp's grammar support.
- #l("explainer-onnx") — the runtime used for non-generative models.

= External links <quantization-external>

- #link("https://github.com/ggml-org/llama.cpp")[llama.cpp] — the runtime.
- #link("https://github.com/ggml-org/ggml/blob/master/docs/gguf.md")[GGUF]
  — the file format's specification.
