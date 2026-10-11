#!/usr/bin/env bash
# Bootstrap a fresh Mac: Xcode CLT, Homebrew, mise, then chezmoi init --apply.
# Safe to run more than once.
set -euo pipefail

readonly DOTFILES_URL="${DOTFILES_URL:-https://github.com/rlemaitre/dotfiles.git}"
readonly BREW_BIN="/opt/homebrew/bin/brew"

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

if [[ ! -x "${BREW_BIN}" ]]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("${BREW_BIN}" shellenv)"

brew list --formula mise >/dev/null 2>&1 || brew install mise

# chezmoi comes from mise; run it without writing mise's global config,
# which chezmoi itself manages later.
mise exec chezmoi@latest -- chezmoi init --apply "${DOTFILES_URL}"
