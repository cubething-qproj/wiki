// Plain HTML results using the collection's local Pagefind index.
(async () => {
  const results = document.getElementById("search-results");
  const status = document.getElementById("search-status");
  const query = new URLSearchParams(location.search).get("q")?.trim();
  if (!query) return;
  document.querySelector('#search input').value = query;
  document.title = `Search: ${query}`;
  status.textContent = `Searching for “${query}”…`;
  try {
    const pagefind = await import(results.dataset.index);
    const search = await pagefind.search(query);
    status.textContent = `${search.results.length} results for “${query}”`;
    let shown = 0;
    const more = document.createElement("button");
    more.type = "button";
    more.textContent = "More results";
    // Load excerpts in small batches, preserving Pagefind's ranking.
    async function showMore() {
      more.disabled = true;
      try {
        const batch = await Promise.all(search.results.slice(shown, shown + 10).map(r => r.data()));
        for (const result of batch) {
          const item = document.createElement("li");
          const heading = document.createElement("h2");
          const link = document.createElement("a");
          link.href = result.url;
          link.textContent = result.meta.title;
          heading.append(link);
          const excerpt = document.createElement("p");
          // Decode Pagefind's excerpt as text without inserting its HTML.
          excerpt.textContent = new DOMParser().parseFromString(result.excerpt, "text/html").body.textContent;
          item.append(heading, excerpt);
          results.append(item);
        }
        shown += batch.length;
        more.hidden = shown >= search.results.length;
      } catch (error) {
        status.textContent = "Could not load results. Please try again.";
        console.error(error);
      } finally {
        more.disabled = false;
      }
    }
    more.addEventListener("click", showMore);
    results.after(more);
    await showMore();
  } catch (error) {
    status.textContent = "Search is unavailable. Please try again.";
    console.error(error);
  }
})();
