#import "../_template.typ": *
#show: wiki-page.with(
  title: [Quantization, GGUF and llama.cpp],
  status: "current",
  summary: [Store weights in fewer bits so models fit and run on a CPU.],
)

A model's weights are normally 16-bit numbers. *Quantizing* stores each
in about 4 bits instead, which cuts size and memory traffic by roughly
4× for a small loss in quality. A 3B-parameter model goes from about 6 GB
to about 2 GB.

*GGUF* is the file format for quantized models used by *llama.cpp*, a
C++ runtime that runs them on a CPU, optionally offloading some layers
to a GPU. `llama-server` exposes it over HTTP.
