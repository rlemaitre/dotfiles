#!/usr/bin/env bash
# Show a Markdown file in the Markdown Preview app (its `mdp` command), without taking focus from the terminal.
# Usage: md-show.sh <file.md>
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "usage: md-show.sh <existing file.md>" >&2
  exit 2
fi

# mdp wraps `open -a "Markdown Preview"`: -g opens the file in the background.
mdp -g "$1"
