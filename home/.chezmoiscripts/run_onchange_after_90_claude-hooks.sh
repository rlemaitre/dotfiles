#!/usr/bin/env bash
# Add the managed hooks to an existing ~/.claude/settings.json:
# - SessionStart: i-have-adhd, always on
# - PreToolUse on mcp__jetbrains__execute_run_configuration: reminder to approve the run in IntelliJ
# - PreToolUse on Write: blocks a whole-file Write over the productivity TASKS.md
# - idea-guard on PreToolUse (Bash), PostToolUse (Edit|Write|NotebookEdit) and UserPromptSubmit: keeps .idea files
#   Claude did not edit out of its commits
# The settings seed (create_private_settings.json) only reaches a Mac that has no settings file yet;
# this script covers the others. Idempotent: each hook is added only when missing.
set -euo pipefail

readonly SETTINGS="${HOME}/.claude/settings.json"
readonly ADHD_COMMAND="bash ~/.claude/hooks/i-have-adhd.sh"
readonly RUN_REMINDER_COMMAND="bash ~/.claude/hooks/intellij-run-reminder.sh"
readonly RUN_REMINDER_MATCHER="mcp__jetbrains__execute_run_configuration"
readonly PROTECT_TASKS_COMMAND="bash ~/.claude/hooks/protect-tasks-md.sh"
readonly IDEA_GUARD_COMMAND="bash ~/.claude/hooks/idea-guard.sh"

[[ -f "${SETTINGS}" ]] || exit 0
command -v jq >/dev/null || {
  echo "jq not found, skipping the Claude hooks" >&2
  exit 0
}

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT
jq --arg adhd "${ADHD_COMMAND}" --arg reminder "${RUN_REMINDER_COMMAND}" --arg matcher "${RUN_REMINDER_MATCHER}" \
  --arg protect "${PROTECT_TASKS_COMMAND}" --arg idea "${IDEA_GUARD_COMMAND}" '
  (if any(.hooks.SessionStart[]?.hooks[]?; .command == $adhd) then .
   else .hooks.SessionStart += [{hooks: [{type: "command", command: $adhd, timeout: 5}]}]
   end)
  | (if any(.hooks.PreToolUse[]?.hooks[]?; .command == $reminder) then .
     else .hooks.PreToolUse += [{matcher: $matcher, hooks: [{type: "command", command: $reminder, timeout: 5}]}]
     end)
  | (if any(.hooks.PreToolUse[]?.hooks[]?; .command == $protect) then .
     else .hooks.PreToolUse += [{matcher: "Write", hooks: [{type: "command", command: $protect, timeout: 5}]}]
     end)
  | (if any(.hooks.PreToolUse[]?.hooks[]?; .command == $idea) then .
     else .hooks.PreToolUse += [{matcher: "Bash", hooks: [{type: "command", command: $idea, timeout: 5}]}]
     end)
  | (if any(.hooks.PostToolUse[]?.hooks[]?; .command == $idea) then .
     else .hooks.PostToolUse += [{matcher: "Edit|Write|NotebookEdit", hooks: [{type: "command", command: $idea, timeout: 5}]}]
     end)
  | (if any(.hooks.UserPromptSubmit[]?.hooks[]?; .command == $idea) then .
     else .hooks.UserPromptSubmit += [{hooks: [{type: "command", command: $idea, timeout: 5}]}]
     end)' "${SETTINGS}" >"${tmp}"
if ! cmp -s "${tmp}" "${SETTINGS}"; then
  chmod 600 "${tmp}"
  mv "${tmp}" "${SETTINGS}"
  echo "added the managed Claude hooks to ${SETTINGS}"
fi
