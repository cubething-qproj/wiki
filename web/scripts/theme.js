// Theme initialization and control copied from ada-x64/blog.
(() => {
    const theme = window.localStorage.getItem("theme") ?? "system";
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const isDark = theme === "dark" || theme === "system" && prefersDark;
    const className = `${theme} ${isDark && theme === "system" ? "dark" : ""}`;
    const html = document.documentElement;
	html.className = className;
    html.setAttribute("data-madoromi", `natsu-${isDark ? "yoru" : "hiru"}`)
})();

const themeCycle = ["system", "light", "dark"];
document.addEventListener("DOMContentLoaded", () => {
	document
		.querySelector(".toggle-lights")
		.addEventListener("click", (_event) => {
			const currentTheme = window.localStorage.getItem("theme") ?? "system";
			const nextThemeIdx = themeCycle.indexOf(currentTheme);
			const theme = themeCycle[(nextThemeIdx + 1) % 3];
			const isDark =
				theme === "dark" ||
				(theme === "system" &&
					window.matchMedia("(prefers-color-scheme: dark)").matches);
			const html = document.querySelector("html");
			const className = `${theme} ${isDark && theme === "system" ? "dark" : ""}`;
			html.className = className;
			html.setAttribute("data-madoromi", `natsu-${isDark ? "yoru" : "hiru"}`);
			window.localStorage.setItem("theme", theme);
		});
});
