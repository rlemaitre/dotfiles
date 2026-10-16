#!/usr/bin/env bash
# Show a Markdown file with `glow --pager` in a Ghostty split next to the focused pane.
# Reuses the split opened by the previous call while it still exists (its id is kept in ~/.cache).
# Usage: glow-split.sh <file.md>
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "usage: glow-split.sh <existing file.md>" >&2
  exit 2
fi

# Only when running inside Ghostty: walk up the process tree. Environment variables are not enough
# (TERM_PROGRAM is unset under Claude Code, and an editor started from a Ghostty shell inherits GHOSTTY_*).
in_ghostty() {
  local pid="$PPID"
  while [[ "${pid}" -gt 1 ]]; do
    [[ "$(ps -o comm= -p "${pid}")" == */Ghostty.app/Contents/MacOS/ghostty ]] && return 0
    pid="$(ps -o ppid= -p "${pid}" | tr -d ' ')"
  done
  return 1
}
if ! in_ghostty; then
  echo "glow-split.sh: not running inside Ghostty, nothing opened" >&2
  exit 3
fi

file="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
state="${XDG_CACHE_HOME:-${HOME}/.cache}/claude-glow-split"
mkdir -p "$(dirname "${state}")"
previous="$(cat "${state}" 2>/dev/null || true)"
cmd="glow --pager $(printf '%q' "${file}")"

# In a reused split: q quits a pager still showing the previous file, Ctrl-C then clears the prompt
# (it drops the q when no pager was running). input text pastes, so enter is sent as a key.
id="$(
  osascript - "${previous}" "${cmd}" <<'EOF'
on run argv
  set previousId to item 1 of argv
  set cmd to item 2 of argv
  tell application "Ghostty"
    if previousId is not "" and (exists terminal id previousId) then
      set t to terminal id previousId
      send key "q" to t
      delay 0.2
      send key "c" modifiers "control" to t
      delay 0.2
      input text cmd to t
      send key "enter" to t
    else
      set cfg to new surface configuration
      set initial input of cfg to cmd & linefeed
      set t to split (focused terminal of selected tab of front window) direction right with configuration cfg
    end if
    return id of t
  end tell
end run
EOF
)"
printf '%s\n' "${id}" >"${state}"
