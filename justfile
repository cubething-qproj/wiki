# Recipes run from this directory (just sets the working directory).

# Serve the wiki: rebuilds and reloads on every change, including new pages.
serve port="3040":
    bun install --silent
    WIKI_PORT={{ port }} bun run vite

# Build the wiki from scratch into out/, with its search index.
build:
    rm -rf out
    python3 scripts/manifest.py
    TYPST_FEATURES=bundle,html typst compile main.typ out --format=bundle
    pagefind --site out --silent
