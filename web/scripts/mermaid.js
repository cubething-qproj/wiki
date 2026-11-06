/**
 * Show a rendered diagram at its natural size, scrolling inside its `pre`,
 * with −/fit/+ controls. Mermaid otherwise shrinks wide diagrams to the
 * column, which makes their text unreadable.
 */
function addZoom(pre) {
  const svg = pre.querySelector("svg");
  if (!svg) return;
  const natural = svg.viewBox.baseVal.width;
  let scale = 1;
  const zoom = (next) => {
    scale = next;
    svg.style.maxWidth = "none";
    svg.style.width = `${natural * scale}px`;
  };
  const controls = document.createElement("div");
  controls.className = "diagram-zoom";
  for (const [label, title, action] of [
    ["−", "Zoom out", () => zoom(scale / 1.25)],
    ["fit", "Fit to column", () => zoom(pre.clientWidth / natural)],
    ["+", "Zoom in", () => zoom(scale * 1.25)],
  ]) {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = label;
    button.title = title;
    button.addEventListener("click", action);
    controls.append(button);
  }
  pre.before(controls);
  zoom(1);
}

// An unavailable diagram CDN must not block DOMContentLoaded or search.
if (document.querySelector("pre.mermaid")) {
  import("https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs")
    .then(async ({ default: mermaid }) => {
      const dark = document.documentElement.classList.contains("dark");
      mermaid.initialize({
        startOnLoad: false,
        securityLevel: "loose",
        deterministicIds: true,
        theme: dark ? "dark" : "default",
      });
      await mermaid.run({ querySelector: "pre.mermaid" });
      for (const pre of document.querySelectorAll("pre.mermaid")) {
        addZoom(pre);
      }
    })
    .catch((error) => console.warn("Diagram rendering unavailable:", error));
}
