#!/usr/bin/env bash
# Usage: run-bloop-main.sh <worktree root> <main file> <main class name>
set -euo pipefail

project_name="$(basename "$1")" # project name from $ZED_WORKTREE_ROOT
filepath="$2"
mainname="$3"

package_name="$(grep -E '^package ' "${filepath}" | sed 's/package //')" # package of the main file

bloop run "${project_name}" -m "${package_name}.${mainname}"
