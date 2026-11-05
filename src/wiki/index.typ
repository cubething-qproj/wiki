#import "../template.typ": *
#show: shell.with(none, collection: "wiki")

Quell is a game about going around and talking to people. In particular, it's
about teaching people how to do philosophy and why. The these include
existential dread, meaning in life, guilt and shame, atonement, forgiveness,
empathy. It's an existential mystery, a Socratic hero's journey.

The game is set in an oak-hickory forest, similar to the ones I grew up around
here in Kansas, where an abandoned university waits to be explored. You'll
encounter philosophical texts both real and hand-written, experience flashbacks
to things you've blocked out, and talk to NPCs about issues we face every day in
the real world.

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
