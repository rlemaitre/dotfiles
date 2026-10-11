#!/usr/bin/env python3
"""Bump the pinned versions in home/.chezmoidata/packages.yaml within their line.

Covers every mise entry (`name@version`), the pinned gh extensions and the pinned gh agent skills.
A line is the major version (`pnpm@10.8.1` follows 10.x.y), or major.minor for 0.x versions (semver allows a
breaking change in any 0.x minor) and for the tools in TWO_PART_LINES (`python@3.12.12` follows 3.12.x).
A newer release in the same line is applied; a newer line is only listed.
The kotlin_lsp block is not touched: it is a stopgap with its own checksum (docs/upstream-watch.md).

  scripts/bump-pins.py                 edit the file, regenerate docs/tools.md, print one line per change
  scripts/bump-pins.py --dry-run       only print
  scripts/bump-pins.py --summary FILE  also write the changes as Markdown (pull request body)
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PACKAGES = ROOT / "home/.chezmoidata/packages.yaml"
TWO_PART_LINES = {"python"}  # version scheme where the minor release is the breaking level
MISE_PIN = re.compile(r'^(\s*- ")([^"]+?)@([^"@/:]+)(")\s*$')
REPO_PIN = re.compile(r"(\{repo: ([\w./-]+)(?:, skill: [\w-]+)?, pin: )(\S+?)(\})")


def numbers(version):
    """Dotted numeric parts of a version, or None when it has anything else (pre-releases...)."""
    parts = version.split(".")
    return tuple(int(p) for p in parts) if all(p.isdigit() for p in parts) else None


def split_pin(pin):
    """('oracle-graalvm-', '21.0.7') for java; ('v', '4.17.0') for a tag."""
    match = re.match(r"^(.*?)(\d+(?:\.\d+)*)$", pin)
    return (match.group(1), match.group(2)) if match else (None, None)


def line_of(tool, parts):
    return parts[: 2 if tool in TWO_PART_LINES or parts[0] == 0 else 1]


def pick(tool, prefix, current, versions):
    """(newest in the current line, newest of a later line) among the versions with the same shape."""
    same_shape = []
    for text in versions:
        if not text.startswith(prefix):
            continue
        parts = numbers(text[len(prefix):])
        if parts and len(parts) == len(current):
            same_shape.append(parts)
    in_line = max((p for p in same_shape if line_of(tool, p) == line_of(tool, current)), default=current)
    later = max((p for p in same_shape if line_of(tool, p) > line_of(tool, current)), default=None)
    fmt = lambda parts: prefix + ".".join(map(str, parts))
    return (fmt(in_line) if in_line > current else None, fmt(later) if later else None)


def mise_versions(tool):
    return subprocess.run(["mise", "ls-remote", tool], capture_output=True, text=True, check=True).stdout.split()


def release_tags(repo):
    out = subprocess.run(
        ["gh", "api", "--paginate", f"repos/{repo}/releases", "--jq",
         ".[] | select(.prerelease == false and .draft == false) | .tag_name"],
        capture_output=True, text=True,
    )
    return out.stdout.split() if out.returncode == 0 else []


def bump(label, tool, pin, versions, applied, listed):
    prefix, version = split_pin(pin)
    current = numbers(version) if version else None
    if current is None:
        return pin
    new, later = pick(tool, prefix, current, versions)
    if later:
        listed.append(f"{label}: {pin} -> {later} (new major or 0.x minor, not applied)")
    if new:
        applied.append(f"{label}: {pin} -> {new}")
        return new
    return pin


def main():
    args = sys.argv[1:]
    dry_run = "--dry-run" in args
    summary = Path(args[args.index("--summary") + 1]) if "--summary" in args else None
    applied, listed, lines = [], [], []
    section = None
    for line in PACKAGES.read_text().splitlines():
        top = re.match(r"^  (\w+):", line)
        if top:
            section = top.group(1)
        match = MISE_PIN.match(line) if section == "mise" else None
        if match:
            tool, pin = match.group(2), match.group(3)
            try:
                new = bump(tool, tool, pin, mise_versions(tool), applied, listed)
            except subprocess.CalledProcessError:
                print(f"cannot list the versions of {tool}: left at {pin}", file=sys.stderr)
                new = pin
            line = f"{match.group(1)}{tool}@{new}{match.group(4)}"
        repo_pin = REPO_PIN.search(line)
        if repo_pin:
            repo, pin = repo_pin.group(2), repo_pin.group(3)
            new = bump(repo, repo, pin, release_tags(repo), applied, listed)
            line = REPO_PIN.sub(lambda m: f"{m.group(1)}{new}{m.group(4)}", line)
        lines.append(line)
    print("\n".join(applied) if applied else "pins are current")
    if listed:
        print("\nnewer major versions or 0.x minors (not applied):\n" + "\n".join(listed))
    if summary:
        parts = []
        if applied:
            parts.append("Moved to the newest release of the same line:\n\n" + "\n".join(f"- {x}" for x in applied))
        if listed:
            parts.append("Newer major versions (or 0.x minors), not applied (read the changelog, then bump by hand):\n\n"
                         + "\n".join(f"- {x}" for x in listed))
        summary.write_text("\n\n".join(parts) + "\n")
    if applied and not dry_run:
        PACKAGES.write_text("\n".join(lines) + "\n")
        # docs/tools.md prints the pinned versions
        subprocess.run([sys.executable, str(ROOT / "scripts/gen-tools-doc.py")], check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
