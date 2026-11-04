"""Source-catalogue and rendered-contract tests; run after `just build`."""

import datetime
import importlib.util
import json
import pathlib
import re
import tempfile
import unittest
from html.parser import HTMLParser
from unittest.mock import patch
from urllib.parse import unquote, urlsplit

ROOT = pathlib.Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location("manifest", ROOT / "scripts/manifest.py")
assert SPEC is not None and SPEC.loader is not None
manifest = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(manifest)


class Page(HTMLParser):
    """Collect links, IDs and text without a browser or third-party parser."""

    def __init__(self, html):
        super().__init__()
        self.links, self.ids, self.text = [], set(), []
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.add(attrs["id"])
        if tag == "a" and "href" in attrs:
            self.links.append(attrs["href"])

    def handle_data(self, data):
        self.text.append(data)


class CatalogueTests(unittest.TestCase):
    def discover(self, *paths):
        """Create a test-local source tree and supply deterministic edit times."""
        with tempfile.TemporaryDirectory(dir=ROOT / "tests") as directory:
            root = pathlib.Path(directory)
            for name in paths:
                p = root / name
                p.parent.mkdir(parents=True, exist_ok=True)
                p.touch()
            with patch.object(
                manifest, "edited_at", return_value="2026-11-03T12:00:00.000000Z"
            ):
                return manifest.discover(root)

    def test_separate_collections_and_ignore_build_artifacts(self):
        pages = self.discover(
            "pcg/proposal.typ",
            "articles/pcg/terrain.typ",
            "portals/pcg.typ",
            "out/generated.typ",
            ".out-next/generated.typ",
            "tests/fixture.typ",
            "node_modules/foreign.typ",
            "scripts/helper.typ",
        )
        self.assertEqual(
            {p["name"]: (p["kind"], p["url"]) for p in pages},
            {
                "proposal": ("document", "/documents/proposal.html"),
                "terrain": ("article", "/wiki/terrain.html"),
                "portal-pcg": ("portal", "/wiki/pcg.html"),
            },
        )

    def test_duplicate_editor_ids_and_urls_are_rejected(self):
        for paths in [
            ("pcg/shared.typ", "articles/pcg/shared.typ"),
            ("articles/pcg/pcg.typ", "portals/pcg.typ"),
            ("articles/pcg/index.typ",),
        ]:
            with self.subTest(paths=paths), self.assertRaises(ValueError):
                self.discover(*paths)

    def test_edit_time_uses_commit_or_working_file_not_build_time(self):
        path = ROOT / "main.typ"
        with patch.object(
            manifest, "git", side_effect=["", "2026-10-01T15:00:00+03:00"]
        ):
            self.assertEqual(manifest.edited_at(path), "2026-10-01T12:00:00.000000Z")
        with patch.object(manifest, "git", return_value=" M main.typ"):
            edited = datetime.datetime.fromisoformat(manifest.edited_at(path))
            self.assertAlmostEqual(edited.timestamp(), path.stat().st_mtime, places=5)


class RenderedTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.out = ROOT / "out"
        cls.pages = json.loads((ROOT / "manifest.json").read_text())["pages"]

    def html(self, url):
        return (self.out / url.lstrip("/")).read_text()

    def test_local_links_and_fragments_resolve_across_collections(self):
        for source in self.out.rglob("*.html"):
            page = Page(source.read_text())
            for href in page.links:
                url = urlsplit(href)
                if url.scheme or url.netloc or url.path.startswith("/editor/"):
                    continue
                target = (
                    (self.out / url.path.lstrip("/"))
                    if url.path.startswith("/")
                    else source.parent / url.path
                )
                if not url.path:
                    target = source
                if target.is_dir():
                    target /= "index.html"
                with self.subTest(source=source.name, href=href):
                    self.assertTrue(target.is_file(), href)
                    if url.fragment and target.is_file():
                        self.assertIn(
                            unquote(url.fragment), Page(target.read_text()).ids
                        )

    def test_outlines_stay_inside_their_article(self):
        for name, prefix in [
            ("terrain-generation", "terrain-"),
            ("trail-layout", "layout-"),
        ]:
            html = self.html(f"/wiki/{name}.html")
            outline = re.search(r'<nav role="doc-toc">(.*?)</nav>', html, re.DOTALL)
            assert outline is not None
            links = Page(outline[1]).links
            self.assertTrue(links)
            self.assertTrue(all(href.startswith("#" + prefix) for href in links), links)

    def test_related_documents_are_explicit_and_newest_first(self):
        catalogue = {p["name"]: p for p in self.pages}
        for name in ["terrain-generation", "trail-layout"]:
            html = self.html(f"/wiki/{name}.html")
            section = re.search(
                r'<section class="related-documents">(.*?)</section>', html, re.DOTALL
            )
            assert section is not None
            names = [
                pathlib.Path(urlsplit(href).path).stem
                for href in Page(section[1]).links
            ]
            expected = re.search(
                r"documents: \((.*?)\)",
                (ROOT / f"articles/pcg/{name}.typ").read_text(),
                re.DOTALL,
            )
            assert expected is not None
            selected = re.findall(r'"([^"]+)"', expected[1])
            self.assertEqual(
                names,
                sorted(
                    selected, key=lambda n: (catalogue[n]["edited"], n), reverse=True
                ),
            )
            self.assertTrue(all(catalogue[n]["kind"] == "document" for n in names))
        text = " ".join(Page(self.html("/wiki/terrain-generation.html")).text)
        self.assertIn("🤔 Undecided", text)

    def test_collection_indexes_and_legacy_redirects(self):
        for collection in ["wiki", "documents"]:
            self.assertTrue((self.out / collection / "pagefind/pagefind.js").is_file())
            self.assertIn(
                f"/{collection}/pagefind/pagefind-ui.js",
                self.html(f"/{collection}/index.html"),
            )
        wiki_links = Page(self.html("/wiki/index.html")).links
        self.assertNotIn("/documents/quell-hex-terrain-r11-design.html", wiki_links)
        document_links = Page(self.html("/documents/pcg.html")).links
        self.assertNotIn("/wiki/terrain-generation.html", document_links)
        for p in self.pages:
            if p["kind"] == "document":
                self.assertIn(
                    'content="0;url=' + p["url"] + '"',
                    self.html("/" + p["name"] + ".html"),
                )


if __name__ == "__main__":
    unittest.main()
