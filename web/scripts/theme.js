// The blog's system → light → dark preference cycle, applied before page paint.
(() => {
  const themes = ["system", "light", "dark"];
  const media = matchMedia("(prefers-color-scheme: dark)");
  const preference = () => {
    try {
      const saved = localStorage.getItem("theme");
      return saved && themes.includes(saved) ? saved : "system";
    } catch {
      return "system";
    }
  };
  const apply = (theme) => {
    const dark = theme === "dark" || (theme === "system" && media.matches);
    document.documentElement.classList.toggle("dark", dark);
    document.documentElement.dataset.madoromi = `natsu-${dark ? "yoru" : "hiru"}`;
    const button = document.getElementById("theme-toggle");
    if (button) button.textContent = `Theme: ${theme}`;
  };
  let current = preference();
  apply(current);
  media.addEventListener("change", () => apply(current));
  document.addEventListener("DOMContentLoaded", () => {
    apply(current);
    document.getElementById("theme-toggle")?.addEventListener("click", () => {
      current = themes[(themes.indexOf(current) + 1) % themes.length];
      try {
        localStorage.setItem("theme", current);
      } catch {
        /* Keep the in-page preference. */
      }
      apply(current);
    });
  });
})();
