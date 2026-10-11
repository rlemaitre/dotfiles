#!/usr/bin/env python3
"""Fail when a relative link or a #anchor in README.md or docs/*.md points nowhere."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FILES = [ROOT / "README.md", *sorted((ROOT / "docs").glob("*.md"))]


def anchors(path):
    found = set()
    for line in path.read_text().splitlines():
        match = re.match(r"^#{1,6}\s+(.*)$", line)
        if match:
            title = match.group(1).replace("`", "").strip().lower()
            found.add(re.sub(r"[^a-z0-9 _-]", "", title).replace(" ", "-"))
    return found


def main():
    problems = []
    for source in FILES:
        for target in re.findall(r"\]\(([^)]+)\)", source.read_text()):
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            path, _, fragment = target.partition("#")
            dest = (source.parent / path).resolve() if path else source.resolve()
            name = source.relative_to(ROOT)
            if not dest.exists():
                problems.append(f"{name}: {target}: no such file")
            elif fragment and dest.suffix == ".md" and fragment not in anchors(dest):
                problems.append(f"{name}: {target}: no heading '{fragment}'")
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 1
    print(f"links ok ({len(FILES)} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
