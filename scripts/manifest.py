"""Discover the two reading collections and write their shared source catalogue.

src/documents and src/reference hold records; src/wiki/<area> holds articles
and each area's index.typ portal. IDs remain unique for the shared
editor, while URLs and search indexes belong to separate collections. Dates
come from the last commit, or file mtime for uncommitted work, never build time.
"""

import datetime
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent


def git(*args: str) -> str:
    """Read metadata from the nested documentation repository."""
    return subprocess.run(
        ["git", "--no-pager", *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    ).stdout.strip()


def edited_at(path: pathlib.Path) -> str:
    """Return a UTC timestamp sortable across committed and working files."""
    rel = str(path.relative_to(ROOT))
    committed = ""
    if git("status", "--porcelain", "--", rel) == "":
        committed = git("log", "-1", "--format=%cI", "--", rel)
    edited = (
        datetime.datetime.fromisoformat(committed)
        if committed
        else datetime.datetime.fromtimestamp(path.stat().st_mtime, datetime.UTC)
    )
    return edited.astimezone(datetime.UTC).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def discover(root: pathlib.Path) -> list[dict[str, str]]:
    """Catalogue source paths without importing procedural directories or output."""
    sources = [
        (p, "document", p.parent.name, p.stem)
        for collection in ("documents", "reference")
        for p in root.glob(f"src/{collection}/*/*.typ")
    ]
    sources += [
        (p, "portal" if p.stem == "index" else "article", p.parent.name,
         "portal-" + p.parent.name if p.stem == "index" else p.stem)
        for p in root.glob("src/wiki/*/*.typ")
    ]
    pages, seen, seen_urls = [], {}, set()
    for path, kind, area, name in sorted(sources):
        if name in seen:
            raise ValueError(f"duplicate page name {name!r}: {seen[name]} and {path}")
        seen[name] = path
        edited = edited_at(path)
        collection = "documents" if kind == "document" else "wiki"
        slug = area if kind == "portal" else name
        url = f"/{collection}/{slug}.html"
        if url in seen_urls or url in (
            "/wiki/index.html",
            "/documents/index.html",
            "/documents/status.html",
        ):
            raise ValueError(f"duplicate or reserved page URL {url!r}: {path}")
        seen_urls.add(url)
        pages.append(
            {
                "name": name,
                "area": area,
                "kind": kind,
                "path": str(path.relative_to(root)),
                "url": url,
                "date": datetime.datetime.fromisoformat(edited)
                .astimezone()
                .date()
                .isoformat(),
                "edited": edited,
            }
        )
    return pages


def main() -> None:
    """Write the catalogue consumed by Typst and the source editor."""
    try:
        pages = discover(ROOT)
    except ValueError as error:
        sys.exit(f"manifest: {error}")
    (ROOT / "manifest.json").write_text(json.dumps({"pages": pages}, indent=1) + "\n")
    print(f"manifest: {len(pages)} pages")


if __name__ == "__main__":
    main()
