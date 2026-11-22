#!/usr/bin/env bash
# Keep the managed hooks of an existing ~/.claude/settings.json in line with the settings seed:
# - adds PreToolUse on Write: blocks a whole-file Write over the productivity TASKS.md
# - removes hooks that plugins now ship: the i-have-adhd loader (i-have-adhd 0.4.1 has its own always-on hook,
#   ~/.claude/.i-have-adhd-always), idea-guard and the IntelliJ run reminder (intellij plugin)
# The settings seed (create_private_settings.json) only reaches a Mac that has no settings file yet;
# this script covers the others. Idempotent.
set -euo pipefail

readonly SETTINGS="${HOME}/.claude/settings.json"
readonly PROTECT_TASKS_COMMAND="bash ~/.claude/hooks/protect-tasks-md.sh"
readonly OLD_COMMANDS='["bash ~/.claude/hooks/i-have-adhd.sh", "bash ~/.claude/hooks/idea-guard.sh", "bash ~/.claude/hooks/intellij-run-reminder.sh"]'

[[ -f "${SETTINGS}" ]] || exit 0
command -v jq >/dev/null || {
  echo "jq not found, skipping the Claude hooks" >&2
  exit 0
}

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT
jq --arg protect "${PROTECT_TASKS_COMMAND}" --argjson old "${OLD_COMMANDS}" '
  (if .hooks then
     .hooks |= (with_entries(.value |= (map(.hooks |= map(select(.command as $c | $old | index($c) | not)))
                                        | map(select(.hooks | length > 0))))
                | with_entries(select(.value | length > 0)))
   else . end)
  | (if any(.hooks.PreToolUse[]?.hooks[]?; .command == $protect) then .
     else .hooks.PreToolUse += [{matcher: "Write", hooks: [{type: "command", command: $protect, timeout: 5}]}]
     end)' "${SETTINGS}" >"${tmp}"
if ! cmp -s "${tmp}" "${SETTINGS}"; then
  chmod 600 "${tmp}"
  mv "${tmp}" "${SETTINGS}"
  echo "updated the managed Claude hooks in ${SETTINGS}"
fi
