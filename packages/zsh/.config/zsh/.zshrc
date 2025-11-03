if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
  if [ -f "$(/opt/homebrew/bin/brew --prefix)/etc/brew-wrap" ];then
      source "$(/opt/homebrew/bin/brew --prefix)/etc/brew-wrap"
  fi
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.localdt}/share/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zinit ice wait'1' lucid
zinit light laggardkernel/zsh-gpg-agent

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  eval "$(oh-my-posh init zsh --config "${XDG_CONFIG_HOME:-$HOME/.config}"/oh-my-posh/nord.json)"
fi
# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
export FZF_DEFAULT_OPTS='--height 100%'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --git --git-repos --color=always --color-scale=all --all --icons always --smart-group --group-directories-first --hyperlink --modified --classify=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza --git --git-repos --color=always --color-scale=all --color-scale-mode=gradient --all --icons always --smart-group --group-directories-first --hyperlink --modified --classify=always --long --no-user --no-permissions --octal-permissions --time-style=relative $realpath'
#zstyle ':fzf-tab:complete:eza:*' fzf-preview 'pistol $realpath'
# Shell integrations
# eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/env.zsh"

# >>> scala-cli completions >>>
fpath=("/Users/raphael.lemaitre/Library/Application Support/ScalaCli/completions/zsh" $fpath)
# <<< scala-cli completions <<<
eval "$(/opt/homebrew/bin/mise activate zsh)"
