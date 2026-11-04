# Recipes run from this directory (just sets the working directory).

# Serve the wiki: rebuilds and reloads on every change, including new pages.
serve port="3040":
    bun install --silent
    WIKI_PORT={{ port }} bun run vite

# Build the wiki from scratch into out/, with its search index.
build:
    bun run scripts/build.mts

# Check source discovery and the built collections, links, outlines and ordering.
test:
    python3 -m unittest discover -s tests -v

# Exercise galleries, themes, search and editing in a bounded headless browser.
# Set WIKI_TEST_PORT to reuse a server that is already running.
smoke:
    bun tests/browser.mjs
