# Recipes run from this directory (just sets the working directory).

# Serve the wiki with live reload. Rerun after adding, removing or renaming a page.
serve port="3040":
    python3 scripts/manifest.py
    TYPST_FEATURES=bundle,html typst watch main.typ out --format=bundle --port {{ port }} --open

# Build the wiki once into out/.
build:
    python3 scripts/manifest.py
    TYPST_FEATURES=bundle,html typst compile main.typ out --format=bundle
