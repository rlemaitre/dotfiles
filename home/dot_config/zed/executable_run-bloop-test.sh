#!/usr/bin/env bash
# Usage: run-bloop-test.sh <worktree root> <test file name>
set -euo pipefail

project_name="$(basename "$1")" # project name from $ZED_WORKTREE_ROOT
filename="$2"

bloop test "${project_name}" -o "*${filename}*"
