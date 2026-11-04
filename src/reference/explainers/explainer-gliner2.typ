#import "../../template.typ": *
#show: wiki-page.with(
  title: [GLiNER2],
  status: "current",
  summary: [Small extraction model that takes its labels at run time.],
)

GLiNER-family models are small encoders that take their labels when you
call them. Ask one to "find spans of type `claim`, `reason`", or to
"classify this as `fact`, `value`, `policy`". New labels need no
training, and it runs on a CPU. It's already planned for the
reading-notes lab, so one integration serves both labs.
