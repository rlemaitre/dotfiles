#!/usr/bin/env zsh

echo "Setting up your Mac..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
else
  echo "Xcode Command Line Tools already installed."
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc

# Update Homebrew recipes
brew update

# Install all our dependencies with brew-file and stow
brew install rcmdnk/file/brew-file
brew install stow

install_package() {
    local base=$1
    local group=$2
    local target
    if [[ ${base} -eq 'root' ]]; then target="/"; else target="${HOME}"; fi
    if [[ -f "packages/${group}.${base}.lst" ]] then
        printf '%s\n' "Installing ${base}-based ${group} packages"
        while read -r LINE
        do
            printf '\t%s\n' "Installing ${LINE} package"
            stow --target="${target}" --dir=./packages ${LINE}
        done < "packages/${group}.${base}.lst"
    fi
}
install_package root common
install_package root ${HOST}
install_package user common
install_package user ${HOST}

brew file install

# Set macOS preferences - we will run this last because this will reload the shell
source macos/set_defaults.sh
