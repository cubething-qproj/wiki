// Generated category-style topic pages. Membership comes from article metadata.
#import "template.typ": page-url, shell, topic-name

/// Extract visible title text for alphabetic ordering, including formatted titles.
#let title-text(body) = {
  if body.has("text") { body.text } else if body.has("children") {
    body.children.map(title-text).join()
  } else if body.has("body") { title-text(body.body) } else { "" }
}

/// A topic's parent portal, membership count and alphabetized article descriptions.
#let topic-page(portal, topic, pages) = shell(
  [Topic: #topic-name(topic)],
  [
    Part of #link(page-url(portal.name), portal.title).

    This topic contains #pages.len() #if pages.len() == 1 [article.] else [articles.]

    #list(
      ..pages
        .sorted(key: p => lower(title-text(p.title)))
        .map(p => [
          #link(page-url(p.name), p.title) — #p.summary
        ]),
    )
  ],
  collection: "wiki",
)
