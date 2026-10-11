#!/usr/bin/env bash
# Tells whether a workaround in this repo can be removed because upstream is fixed.
#
# kotlin-lsp: the Homebrew formula jetbrains/utils/kotlin-lsp downloads an archive that returned 404, so
# the repo installs the server from JetBrains' VS Code extension archive instead (see docs/upstream-watch.md).
# The formula counts as fixed when every download URL it declares answers HTTP 200.
#
# Exit codes: 0 = still broken (nothing to do), 10 = fixed (switch back), 1 = the check itself failed.
# Override the formula location for tests: KOTLIN_LSP_FORMULA_URL=file:///path/to/kotlin-lsp.rb
set -euo pipefail

readonly FORMULA_URL="${KOTLIN_LSP_FORMULA_URL:-https://raw.githubusercontent.com/JetBrains/homebrew-utils/master/Formula/kotlin-lsp.rb}"
readonly UPSTREAM_ISSUE="Kotlin/kotlin-lsp/issues/282"

formula="$(curl -fsSL "${FORMULA_URL}")" || {
  echo "cannot read the formula at ${FORMULA_URL}" >&2
  exit 1
}

version="$(sed -nE 's/^[[:space:]]*version "([^"]+)".*/\1/p' <<<"${formula}" | head -n 1)"
if [[ -z "${version}" ]]; then
  echo "no version found in the formula" >&2
  exit 1
fi

mapfile -t urls < <(grep -oE 'url "[^"]+"' <<<"${formula}" | sed -E 's/^url "//; s/"$//; s/#\{version\}/'"${version}"'/g')
if ((${#urls[@]} == 0)); then
  echo "no download url found in the formula" >&2
  exit 1
fi

echo "kotlin-lsp formula ${version}"
fixed=1
for url in "${urls[@]}"; do
  status="$(curl -sIL -o /dev/null -w '%{http_code}' "${url}" || true)"
  echo "  HTTP ${status}  ${url}"
  [[ "${status}" == "200" ]] || fixed=0
done

# Informational: the upstream bug report.
if command -v gh >/dev/null 2>&1; then
  state="$(gh api "repos/${UPSTREAM_ISSUE}" --jq '.state' 2>/dev/null || echo unknown)"
  echo "  upstream issue ${UPSTREAM_ISSUE}: ${state}"
fi

if ((fixed)); then
  echo "FIXED: the Homebrew formula downloads again. Switch back: see docs/upstream-watch.md"
  exit 10
fi
echo "still broken: keep the install script"
