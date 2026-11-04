addEventListener("DOMContentLoaded", () => {
  // Blog-style gallery controls enhance native touch and keyboard scrolling.
  for (const wrap of document.querySelectorAll(".carousel-wrap")) {
    const list = wrap.querySelector(".carousel");
    if (!list) continue;
    for (const { selector, direction } of [
      { selector: ".prev", direction: -1 },
      { selector: ".next", direction: 1 },
    ]) {
      wrap.querySelector(selector)?.addEventListener("click", () => {
        list.scrollBy({
          left: direction * list.clientWidth,
          behavior: matchMedia("(prefers-reduced-motion: reduce)").matches
            ? "auto"
            : "smooth",
        });
      });
    }
  }
  // Typst appends native HTML endnotes outside the authored shell.
  const notes = document.querySelector("body > section[role=doc-endnotes]");
  const main = document.querySelector("main");
  if (notes && main) {
    const heading = document.createElement("h2");
    heading.textContent = "Notes and references";
    notes.prepend(heading);
    main.insertBefore(
      notes,
      main.querySelector(".related-documents, .backlinks"),
    );
  }
});
