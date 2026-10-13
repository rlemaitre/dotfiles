#!/usr/bin/env bash
# SessionStart hook: load the i-have-adhd skill into every session. The skill only runs on
# /i-have-adhd (disable-model-invocation), so this prints its rules for Claude Code to add as context.
# Uses the newest cached plugin version, so plugin updates are picked up. Prints nothing if not installed.
set -euo pipefail

readonly CACHE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cache/i-have-adhd/i-have-adhd"

skill="$(find "${CACHE}" -path '*/skills/i-have-adhd/SKILL.md' 2>/dev/null | sort -V | tail -n 1 || true)"
[[ -n "${skill}" ]] || exit 0

echo "ADHD MODE ACTIVE for this session (from the i-have-adhd plugin). Follow these rules:"
echo
# drop the YAML front matter
awk 'NR == 1 && /^---$/ { fm = 1; next } fm && /^---$/ { fm = 0; next } !fm' "${skill}"
