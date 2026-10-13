#!/usr/bin/env bash
# Add the managed SessionStart hook (i-have-adhd, always on) to an existing ~/.claude/settings.json.
# The settings seed (create_private_settings.json) only reaches a Mac that has no settings file yet;
# this script covers the others. Idempotent: the hook is added only when missing.
set -euo pipefail

readonly SETTINGS="${HOME}/.claude/settings.json"
readonly COMMAND="bash ~/.claude/hooks/i-have-adhd.sh"

[[ -f "${SETTINGS}" ]] || exit 0
command -v jq >/dev/null || {
  echo "jq not found, skipping the Claude hooks" >&2
  exit 0
}

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT
jq --arg cmd "${COMMAND}" '
  if any(.hooks.SessionStart[]?.hooks[]?; .command == $cmd) then .
  else .hooks.SessionStart += [{hooks: [{type: "command", command: $cmd, timeout: 5}]}]
  end' "${SETTINGS}" >"${tmp}"
if ! cmp -s "${tmp}" "${SETTINGS}"; then
  chmod 600 "${tmp}"
  mv "${tmp}" "${SETTINGS}"
  echo "added the i-have-adhd SessionStart hook to ${SETTINGS}"
fi
