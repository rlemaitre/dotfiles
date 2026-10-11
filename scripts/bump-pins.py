#!/usr/bin/env python3
"""Bump the pinned versions in home/.chezmoidata/packages.yaml to the latest release of the same line.

Covers the mise pins that name a full version (`pnpm@10.8.1`: newest 10.x.y; a partial pin like
`python@3.12` is left alone) and the pinned gh agent skills (newest release of their repository).
The kotlin_lsp block is not touched: it is a stopgap with its own checksum (docs/upstream-watch.md).

  scripts/bump-pins.py            edit the file, regenerate docs/tools.md, print one line per change
  scripts/bump-pins.py --dry-run  only print
"""
import json
import re
import subprocess
import sys
from pathlib import Path

PACKAGES = Path(__file__).resolve().parent.parent / "home/.chezmoidata/packages.yaml"
MISE_PIN = re.compile(r'^(\s*- ")([^"@]+)@([^"]+)(")\s*$')
SKILL_PIN = re.compile(r"(repo: ([\w./-]+), skill: [\w-]+, pin: )(\S+?)(\})")


def numbers(version):
    """Dotted numeric parts of a version, or None when it has anything else (pre-releases...)."""
    parts = version.split(".")
    return tuple(int(p) for p in parts) if all(p.isdigit() for p in parts) else None


def split_pin(tool, pin):
    """(prefix, numeric version) of a pin: java's `oracle-graalvm-21.0.7` has a prefix."""
    match = re.match(r"^(.*?)(\d+(?:\.\d+)*)$", pin)
    return (match.group(1), match.group(2)) if match else (None, None)


def newest_in_line(tool, pin):
    prefix, version = split_pin(tool, pin)
    current = numbers(version) if version else None
    if current is None or len(current) < 3:
        return None  # partial pin such as python@3.12: it follows the line by itself
    out = subprocess.run(["mise", "ls-remote", tool], capture_output=True, text=True, check=True).stdout
    candidates = []
    for line in out.split():
        if not line.startswith(prefix):
            continue
        parts = numbers(line[len(prefix):])
        # same major, same number of parts: java's odd 21.0.12.1.1 builds are not releases of the pinned kind
        if parts and parts[0] == current[0] and len(parts) == len(current):
            candidates.append(parts)
    if not candidates:
        return None
    best = max(candidates)
    return prefix + ".".join(map(str, best)) if best > current else None


def latest_release(repo):
    out = subprocess.run(
        ["gh", "api", f"repos/{repo}/releases/latest"], capture_output=True, text=True
    )
    return json.loads(out.stdout)["tag_name"] if out.returncode == 0 else None


def main():
    dry_run = "--dry-run" in sys.argv[1:]
    changes, lines = [], []
    for line in PACKAGES.read_text().splitlines():
        match = MISE_PIN.match(line)
        if match:
            tool, pin = match.group(2), match.group(3)
            new = newest_in_line(tool, pin)
            if new:
                changes.append(f"{tool}: {pin} -> {new}")
                line = f"{match.group(1)}{tool}@{new}{match.group(4)}"
        skill = SKILL_PIN.search(line)
        if skill:
            repo, pin = skill.group(2), skill.group(3)
            new = latest_release(repo)
            if new and new != pin:
                changes.append(f"{repo} skill: {pin} -> {new}")
                line = SKILL_PIN.sub(lambda m: f"{m.group(1)}{new}{m.group(4)}", line)
        lines.append(line)
    if not changes:
        print("pins are current")
        return 0
    print("\n".join(changes))
    if not dry_run:
        PACKAGES.write_text("\n".join(lines) + "\n")
        # docs/tools.md prints the pinned versions
        subprocess.run([sys.executable, str(PACKAGES.parents[2] / "scripts/gen-tools-doc.py")], check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
