#!/usr/bin/env bash
# Print what is installed on this Mac, as markdown, to compare machines.
# Read-only. Usage: scripts/inventory.sh > "inventory-$(hostname -s).md"
set -uo pipefail

section() { printf '\n## %s\n\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

printf '# Inventory: %s (%s)\n' "$(hostname -s)" "$(date +%F)"

section "brew taps"
if have brew; then brew tap; else echo "brew not installed"; fi

section "brew formulae (installed on request)"
if have brew; then brew leaves --installed-on-request 2>/dev/null || brew leaves; fi

section "brew casks"
if have brew; then brew list --cask; fi

section "App Store apps (id name)"
if have mas; then mas list | sed -E 's/ +\([^)]*\)$//'; else echo "mas not installed"; fi

section "mise global tools"
if have mise && have jq; then
  mise ls --global --json 2>/dev/null | jq -r '
    to_entries[]
    | .key + (if (.value[0].requested_version // "latest") == "latest" then "" else "@" + .value[0].requested_version end)'
else
  echo "mise or jq not installed"
fi

section "gh extensions"
if have gh; then gh extension list 2>/dev/null | awk '{print $2}'; fi

section "apps in /Applications and ~/Applications (top level and one folder deep)"
for base in /Applications "${HOME}/Applications"; do
  [[ -d "${base}" ]] || continue
  find "${base}" -maxdepth 2 -name '*.app' -not -path '*.app/*' 2>/dev/null | sed "s|^${HOME}|~|" | sort
done
