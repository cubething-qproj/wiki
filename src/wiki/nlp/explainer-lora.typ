#import "../../template.typ": *
#show: article.with(
  title: [LoRA fine-tuning],
  summary: [Adapting a model to a task by training small add-on matrices while its original weights stay frozen.],
  authors: ("Claude Opus 5.5",),
  date: "2026-11-04",
  topic: "Generating text",
  documents: ("debate-spike",),
)

*Low-rank adaptation* (LoRA) is a cheap way to fine-tune a large model. The
original weights are left untouched. Small additional matrices are trained
alongside some of the weight matrices and added to their output. Because
these matrices are low-rank, they add few parameters to train. Fine-tuning
therefore needs far less memory than retraining the whole model, and the
result is a small file that can be applied on top of the base model.

= In Quell <lora-quell>

LoRA is a possible later optimization for argument analysis. A model
fine-tuned on reviewed argument maps would no longer need worked examples in
every prompt, which would shorten prompts and speed up processing on a CPU.
It needs a substantial amount of reviewed data first, so it is deferred until
the source materials have settled.

= See also <lora-see-also>

- #l("explainer-in-context-learning") — the prompt-based alternative it would
  replace.

= References <lora-references>

- Hu, E. J., et al. (2021). LoRA: Low-rank adaptation of large language
  models. #link("https://arxiv.org/abs/2106.09685")[arXiv:2106.09685].
