#!/usr/bin/env bash
# Clone the private workspace repository (rules, context files, templates) to ~/Developer/workspace
# when it is missing, then create the folders that stay local to each machine. Runs on every apply,
# so it retries after a late `gh auth login`. It never pulls, never overwrites and never touches an
# existing folder: update an existing workspace yourself (`git -C ~/Developer/workspace pull`).
set -euo pipefail

readonly REPO="rlemaitre/workspace"
readonly TARGET="${HOME}/Developer/workspace"

if [[ -d "${TARGET}/.git" ]]; then
  exit 0
fi

if [[ -e "${TARGET}" ]]; then
  echo "${TARGET} exists but is not a git clone of ${REPO}: leaving it alone" >&2
  exit 0
fi

command -v gh >/dev/null || {
  echo "gh not found, skipping the workspace clone" >&2
  exit 0
}

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not logged in: run 'gh auth login' then 'chezmoi apply' again to clone ${REPO}" >&2
  exit 0
fi

mkdir -p "$(dirname "${TARGET}")"
gh repo clone "${REPO}" "${TARGET}"
# local to each machine, never in the repository (see the workspace .gitignore)
mkdir -p "${TARGET}/03_projects" "${TARGET}/04_outputs" "${TARGET}/99_archive"
echo "workspace cloned to ${TARGET}. Run 'mise trust' in it to use its tasks."
