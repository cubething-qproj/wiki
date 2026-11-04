#import "../_template.typ": *
#show: wiki-page.with(
  title: [LoRA fine-tuning],
  status: "current",
  summary: [Cheap fine-tuning by training small add-on matrices.],
)

*LoRA* fine-tunes a model by training small low-rank matrices added to
its weights, leaving the original frozen. It needs far less memory than
full fine-tuning, and the result is a small file.

For us: once a model learns the notation from gold data, the few-shot
examples can be dropped from the prompt, which cuts prompt time. Needs
enough gold data, so it comes after the materials settle.
