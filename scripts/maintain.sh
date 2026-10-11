#!/usr/bin/env bash
# Weekly upkeep, run by the LaunchAgent com.rlemaitre.maintain (Sundays, or at wake-up when the Mac slept):
#   1. upgrade Homebrew formulae (never casks or pinned mise tools: those change through the repo) and clean up;
#   2. write a report of what needs attention and notify when something does.
# Usage: scripts/maintain.sh [--report-only]   (report-only changes nothing and prints the report)
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
readonly REPO
readonly DATA="${REPO}/home/.chezmoidata/packages.yaml"
readonly LOG_DIR="${HOME}/Library/Logs/dotfiles"
readonly REPORT="${LOG_DIR}/report.md"
readonly GITHUB_REPO="rlemaitre/dotfiles"

report_only=0
[[ "${1:-}" == "--report-only" ]] && report_only=1

mkdir -p "${LOG_DIR}"
export PATH="${HOME}/.local/share/mise/shims:/opt/homebrew/bin:${PATH}"
export HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_AUTO_UPDATE=1

machine="$(chezmoi data --format json 2>/dev/null | jq -r '.machine // empty')"
if [[ -z "${machine}" ]]; then
  echo "cannot read the machine name from chezmoi" >&2
  exit 1
fi

attention=()
note() { attention+=("$1"); }

# ---- 1. upgrades -------------------------------------------------------------------------------
upgrade_log=""
if ((! report_only)); then
  echo "== $(date '+%F %T') upgrade"
  step() {
    echo "-- $*"
    if ! "$@"; then
      note "failed: $*"
    fi
  }
  step brew update
  upgrade_log="$(brew outdated --formula 2>/dev/null)"
  step brew upgrade --formula
  step brew cleanup
  step mise prune --yes
fi

# ---- 2. report ---------------------------------------------------------------------------------
declared() { # declared <yq expression for a list that exists in common and per machine>
  yq "${1//MACHINE/${machine}}" "${DATA}" 2>/dev/null | sed 's|.*/||' | sort -u
}
declared_ids() {
  yq ".packages.mas.common | keys | .[], .packages.mas[\"${machine}\"] | keys | .[]" "${DATA}" 2>/dev/null | sort -u
}
only_in_first() { comm -23 <(printf '%s\n' "$1" | sort -u) <(printf '%s\n' "$2" | sort -u) | sed '/^$/d'; }

formulae="$(declared '.packages.brew.formulae.common[], .packages.brew.formulae["MACHINE"][]')"
casks="$(declared '.packages.brew.casks.common[], .packages.brew.casks["MACHINE"][]')"
ids="$(declared_ids)"

installed_formulae="$(brew leaves --installed-on-request 2>/dev/null | sed 's|.*/||')"
installed_casks="$(brew list --cask 2>/dev/null)"
installed_ids="$(mas list 2>/dev/null | awk '{print $1}')"

undeclared_formulae="$(only_in_first "${installed_formulae}" "${formulae}")"
undeclared_casks="$(only_in_first "${installed_casks}" "${casks}")"
undeclared_ids="$(only_in_first "${installed_ids}" "${ids}")"
missing_formulae="$(only_in_first "${formulae}" "$(brew list --formula 2>/dev/null | sed 's|.*/||')")"
missing_casks="$(only_in_first "${casks}" "${installed_casks}")"
missing_ids="$(only_in_first "${ids}" "${installed_ids}")"
missing_mise="$(mise ls --missing 2>/dev/null | awk 'NF {print $1 "@" $2}')"
outdated_casks="$(brew outdated --cask 2>/dev/null)"
outdated_formulae="$(brew outdated --formula 2>/dev/null)"
drifted_files="$(chezmoi status --exclude=scripts 2>/dev/null)"

# https, not the ssh remote: a LaunchAgent has no ssh agent (the repo is public)
git -C "${REPO}" fetch --quiet "https://github.com/${GITHUB_REPO}.git" main 2>/dev/null
behind="$(git -C "${REPO}" rev-list --count HEAD..FETCH_HEAD 2>/dev/null || echo 0)"
unpushed="$(git -C "${REPO}" rev-list --count FETCH_HEAD..HEAD 2>/dev/null || echo 0)"
uncommitted="$(git -C "${REPO}" status --porcelain 2>/dev/null)"

open_prs=""
if gh auth status >/dev/null 2>&1; then
  open_prs="$(gh pr list --repo "${GITHUB_REPO}" --state open --json number,title --jq '.[] | "#\(.number) \(.title)"' 2>/dev/null)"
fi

"${REPO}/scripts/check-upstream.sh" >/dev/null 2>&1
[[ $? -eq 10 ]] && note "kotlin-lsp: the Homebrew formula works again, see docs/upstream-watch.md"

fence='```'
body=""
section() { # section <title> <hint> <body>: counted and added to the report only when the body is not empty
  [[ -n "$3" ]] || return 0
  note "$1"
  body+="$(printf '\n## %s\n\n%s\n\n%stext\n%s\n%s\n' "$1" "$2" "${fence}" "$3" "${fence}")"$'\n'
}

section "Repo is behind GitHub (${behind} commits)" "Run \`chezmoi update\`." "$([[ ${behind} -gt 0 ]] && git -C "${REPO}" log --oneline HEAD..FETCH_HEAD)"
section "Unpushed commits (${unpushed})" "Run \`git -C ${REPO} push\`." "$([[ ${unpushed} -gt 0 ]] && git -C "${REPO}" log --oneline FETCH_HEAD..HEAD)"
section "Uncommitted changes in the repo" "Commit or discard them." "${uncommitted}"
section "Open pull requests" "A weekly pin bump waits for review (\`gh pr checkout <n> && mise run check\`)." "${open_prs}"
section "Managed files that differ from the repo" "\`chezmoi diff\`, then \`chezmoi re-add <file>\` or \`chezmoi apply --force <file>\`." "${drifted_files}"
section "Installed but not in packages.yaml: formulae" "Add to \`${machine}\` or \`common\`, or uninstall." "${undeclared_formulae}"
section "Installed but not in packages.yaml: casks" "Add to \`${machine}\` or \`common\`, or uninstall." "${undeclared_casks}"
section "Installed but not in packages.yaml: App Store ids" "Add to \`${machine}\` or \`common\`, or \`mas uninstall\`." "${undeclared_ids}"
section "In packages.yaml but not installed: formulae" "\`chezmoi apply\` installs them." "${missing_formulae}"
section "In packages.yaml but not installed: casks" "\`chezmoi apply\` installs them." "${missing_casks}"
section "In packages.yaml but not installed: App Store ids" "\`chezmoi apply\` installs them." "${missing_ids}"
section "mise tools not installed" "\`mise install\`." "${missing_mise}"
section "Outdated casks" "\`brew upgrade --cask <name>\` (close the app first)." "${outdated_casks}"
section "Outdated formulae" "Held back or failed: \`brew upgrade --formula\`." "${outdated_formulae}"

{
  printf '# Dotfiles upkeep: %s, %s\n\n' "${machine}" "$(date '+%F %T')"
  if ((report_only)); then echo "Report only: nothing was upgraded."; else
    echo "Formulae outdated before the upgrade:"
    printf '\n%stext\n%s\n%s\n' "${fence}" "${upgrade_log:-none}" "${fence}"
  fi
  if ((${#attention[@]} == 0)); then printf '\nNothing needs attention.\n'; else
    printf '\n**Needs attention (%d):**\n\n' "${#attention[@]}"
    printf -- '- %s\n' "${attention[@]}"
  fi
  printf '%s\n' "${body}"
} >"${REPORT}"

if ((report_only)); then
  cat "${REPORT}"
elif ((${#attention[@]} > 0)); then
  osascript -e "display notification \"${#attention[@]} item(s) need attention: see ~/Library/Logs/dotfiles/report.md\" with title \"dotfiles ${machine}\"" 2>/dev/null || true
fi
echo "report: ${REPORT}"
