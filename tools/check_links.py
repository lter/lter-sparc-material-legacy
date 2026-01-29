#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from html.parser import HTMLParser
from pathlib import Path, PurePosixPath
from urllib.parse import urlparse

import yaml


class LinkParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        for name, value in attrs:
            if name in {"href", "src"} and value:
                self.links.append(value)


def load_base_path(config_path: Path) -> str:
    if not config_path.exists():
        return "/"
    config = yaml.safe_load(config_path.read_text()) or {}
    site_url = config.get("site_url", "") or ""
    parsed = urlparse(site_url)
    base_path = parsed.path or "/"
    if not base_path.startswith("/"):
        base_path = f"/{base_path}"
    if not base_path.endswith("/"):
        base_path = f"{base_path}/"
    return base_path


def candidate_targets(rel_path: str) -> list[str]:
    if rel_path.endswith("/"):
        return [f"{rel_path}index.html"]
    suffix = PurePosixPath(rel_path).suffix
    if suffix:
        return [rel_path]
    return [f"{rel_path}/index.html", f"{rel_path}.html"]


def resolve_link(link: str, current_file: Path, build_dir: Path, base_path: str) -> list[Path]:
    if link.startswith("/"):
        if not link.startswith(base_path):
            return []
        rel = link[len(base_path) :]
        rel = rel.lstrip("/")
        return [build_dir / target for target in candidate_targets(rel)]
    rel = link
    current_dir = current_file.parent
    resolved = []
    for target in candidate_targets(rel):
        resolved.append((current_dir / target).resolve())
    return resolved


def is_external(link: str) -> bool:
    parsed = urlparse(link)
    if parsed.scheme in {"http", "https", "mailto", "tel", "javascript"}:
        return True
    if parsed.netloc:
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Check internal links in a built MkDocs site.")
    parser.add_argument("build_dir", nargs="?", default="site", help="Directory of the built site.")
    parser.add_argument(
        "--config",
        default="mkdocs.yml",
        help="Path to mkdocs.yml for determining the base URL path.",
    )
    args = parser.parse_args()

    build_dir = Path(args.build_dir)
    config_path = Path(args.config)
    if not build_dir.exists():
        print(f"Build directory not found: {build_dir}", file=sys.stderr)
        return 2

    base_path = load_base_path(config_path)
    broken: dict[Path, list[str]] = defaultdict(list)

    for html_file in build_dir.rglob("*.html"):
        parser = LinkParser()
        parser.feed(html_file.read_text(encoding="utf-8"))
        for raw_link in parser.links:
            if raw_link.startswith("#") or raw_link.strip() == "":
                continue
            if is_external(raw_link):
                continue
            link = raw_link.split("#", 1)[0]
            candidates = resolve_link(link, html_file, build_dir, base_path)
            if not candidates:
                broken[html_file].append(raw_link)
                continue
            if any(candidate.exists() for candidate in candidates):
                continue
            broken[html_file].append(raw_link)

    if broken:
        print("Broken internal links detected:\n")
        for source, links in sorted(broken.items()):
            rel_source = source.relative_to(build_dir)
            print(f"- {rel_source}")
            for link in sorted(set(links)):
                print(f"  - {link}")
            print()
        return 1

    print("No broken internal links detected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
