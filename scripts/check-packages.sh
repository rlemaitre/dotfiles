#!/usr/bin/env bash
# Fail when a tool appears in more than one channel (mise, brew formula, brew cask) on a machine,
# or when a mise entry has no pinned version.
set -euo pipefail

file="$(cd "$(dirname "$0")/.." && pwd)/home/.chezmoidata/packages.yaml"
status=0

names() {
  yq ".packages.mise.common[], .packages.mise[\"$1\"][],
      .packages.brew.formulae.common[], .packages.brew.formulae[\"$1\"][],
      .packages.brew.casks.common[], .packages.brew.casks[\"$1\"][]" "${file}"
}

while read -r machine; do
  [[ "${machine}" == "common" ]] && continue
  dups="$(names "${machine}" | sed -E 's/@[^@\/:]+$//; s/^[a-z]+://; /^@/!s|^.*/||' | sort | uniq -d)"
  if [[ -n "${dups}" ]]; then
    echo "duplicate on ${machine}:" >&2
    while read -r dup; do echo "  ${dup}" >&2; done <<<"${dups}"
    status=1
  fi
done < <(yq '.packages.mise | keys | .[]' "${file}")

# Every mise entry must be pinned (`name@version`): scripts/bump-pins.py moves the pins.
unpinned="$(yq '.packages.mise[][]' "${file}" | grep -vE '@[^@/:]+$' || true)"
if [[ -n "${unpinned}" ]]; then
  echo "mise entries without a pinned version:" >&2
  while read -r entry; do echo "  ${entry}" >&2; done <<<"${unpinned}"
  status=1
fi

exit "${status}"
