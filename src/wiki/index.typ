#import "../template.typ": *
#show: shell.with(none, collection: "wiki")

Quell is a game in development, built with Bevy. The plan is for its players
to explore generated landscapes, read real philosophy found along the way, and
debate the characters they meet. Start with the project overview, or pick an
area below.

#html.div(class: "main-page-cards")[
  #context {
    let pages = all-pages()
    let orders = query(<topic-order>).map(m => m.value)
    for a in areas {
      let portal = pages.find(p => p.kind == "portal" and p.area == a.id)
      if portal == none { continue }
      let order = orders.find(o => o.area == a.id)
      let topics = if order == none { () } else { order.topics }
      html.elem("div", attrs: (class: "portal"))[
        == #link(page-url(portal.name))[#portal.title]
        #portal.summary
        #topic-list(a.id, topics: topics)
      ]
    }
  }
]
