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
    })
    .catch((error) => console.warn("Diagram rendering unavailable:", error));
}
