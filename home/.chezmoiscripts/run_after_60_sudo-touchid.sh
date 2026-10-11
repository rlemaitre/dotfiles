#!/usr/bin/env bash
# Touch ID for sudo. /etc/pam.d/sudo_local is root-owned and outside $HOME, so it is
# written with sudo. Runs on every apply (cheap check) so it retries after a skipped run.
set -euo pipefail

readonly PAM_FILE="/etc/pam.d/sudo_local"

if grep -qsE '^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "${PAM_FILE}"; then
  exit 0
fi

if [[ ! -t 0 ]]; then
  echo "Touch ID for sudo not configured and no terminal available: run 'chezmoi apply' from a terminal" >&2
  exit 0
fi

echo "Enabling Touch ID for sudo (needs your password once)"
printf '%s\n%s\n' \
  "# sudo_local: local config file which survives system update and is included for sudo" \
  "auth       sufficient     pam_tid.so" | sudo tee "${PAM_FILE}" >/dev/null
