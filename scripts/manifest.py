"""Write manifest.json: every wiki page, its area and its last-changed date.

Typst can't list directories, so `main.typ` reads this file to know which
pages exist. A page is any `.typ` file in an area directory (one level below
the wiki root). Its name is the file stem and must be unique, because pages
are written flat (`<name>.html`) so relative links work everywhere.

The date is the last commit touching the file, or its modification time if
it is new or has uncommitted changes.

Run from anywhere: `python3 .docs/wiki/scripts/manifest.py`.
"""

import datetime
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True).stdout.strip()


def date_of(path: pathlib.Path) -> str:
    rel = str(path.relative_to(ROOT))
    if git("status", "--porcelain", "--", rel) == "":
        committed = git("log", "-1", "--format=%cs", "--", rel)
        if committed:
            return committed
    return datetime.date.fromtimestamp(path.stat().st_mtime).isoformat()


def main() -> None:
    pages, seen = [], {}
    for path in sorted(ROOT.glob("*/*.typ")):
        area = path.parent.name
        if area in ("scripts", "out"):
            continue
        name = path.stem
        if name in seen:
            sys.exit(f"manifest: duplicate page name {name!r}: {seen[name]} and {path}")
        seen[name] = path
        pages.append({"name": name, "area": area, "path": str(path.relative_to(ROOT)), "date": date_of(path)})
    (ROOT / "manifest.json").write_text(json.dumps({"pages": pages}, indent=1) + "\n")
    print(f"manifest: {len(pages)} pages")


if __name__ == "__main__":
    main()
