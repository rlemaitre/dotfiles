#!/usr/bin/env bash
# Fail when a tool appears in more than one channel (mise, brew formula, brew cask) on a machine.
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

exit "${status}"
