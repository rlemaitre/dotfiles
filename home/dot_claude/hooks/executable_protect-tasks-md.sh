#!/usr/bin/env bash
# PreToolUse hook on Write: blocks a whole-file Write over the productivity TASKS.md. A session holding an old copy
# once wrote it back and lost a week of edits; targeted Edit calls cannot do that. Creating the file is allowed.
set -euo pipefail

readonly TASKS="${HOME}/Developer/workspace/02_context/productivity/TASKS.md"

path="$(jq -r '.tool_input.file_path // empty')"
[[ -n "${path}" && -f "${TASKS}" ]] || exit 0
[[ "$(realpath "${path}" 2>/dev/null || echo "${path}")" == "$(realpath "${TASKS}")" ]] || exit 0

echo "Do not rewrite TASKS.md with Write: re-read it and change only the lines you need with Edit." >&2
exit 2
