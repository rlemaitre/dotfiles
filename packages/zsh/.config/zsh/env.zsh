#GPG
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# EDITOR
export EDITOR=nvim
export VISUAL=nvim

# PATH
export PATH="$(brew --prefix)/bin:$HOME/.local/bin:$PATH"

# Proton Drive directory
export PROTON_DRIVE_DIR="$HOME/Library/CloudStorage/ProtonDrive-raphael@rlemaitre.com-folder"

# Homebrew
HOMEBREW_NO_ENV_HINTS=1
