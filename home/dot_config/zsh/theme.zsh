#! /usr/bin/env zsh
#
# Theme: Catppuccin Latte (light) or Mocha (dark), chosen from the macOS appearance when a
# shell starts. It feeds the tools that cannot follow the system by themselves.
# Ghostty, Zed, Neovim and bat (when BAT_THEME is unset) follow the system on their own.
#
# After changing the macOS appearance, open a new shell. To force a mode:
#   THEME_MODE=dark zsh
#
# Sourced from .zshrc before the plugins load (the syntax highlighting theme must come first).

if [[ -z "${THEME_MODE:-}" ]]; then
  if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
    THEME_MODE=dark
  else
    THEME_MODE=light
  fi
fi
export THEME_MODE

if [[ "${THEME_MODE}" == "dark" ]]; then
  export THEME_FLAVOR=mocha
  _theme_jq_colors='38;5;103:38;5;211:38;5;116:38;5;216:38;5;151:38;5;189:38;5;189:38;5;111;1'
  _theme_fzf_colors='bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8,fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC,marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8,selected-bg:#45475A,border:#313244,label:#CDD6F4'
else
  export THEME_FLAVOR=latte
  _theme_jq_colors='38;5;246:38;5;161:38;5;30:38;5;202:38;5;70:38;5;240:38;5;240:38;5;27;1'
  _theme_fzf_colors='bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39,fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78,marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39,selected-bg:#BCC0CC,border:#CCD0DA,label:#4C4F69'
fi

# bat and delta (delta only reads a single BAT_THEME; its colours come from the DELTA_FEATURES feature)
export BAT_THEME="Catppuccin ${(C)THEME_FLAVOR}"
export DELTA_FEATURES="+catppuccin-${THEME_FLAVOR}"

# eza, lazygit and gh-dash read one config; point them at the flavour's file
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME}/eza/${THEME_FLAVOR}"
export LG_CONFIG_FILE="${XDG_CONFIG_HOME}/lazygit/config.yml,${XDG_CONFIG_HOME}/lazygit/themes/catppuccin-${THEME_FLAVOR}.yml"
export GH_DASH_CONFIG="${XDG_CONFIG_HOME}/gh-dash/${THEME_FLAVOR}.yml"

# fzf (and fzf-tab, which reads FZF_DEFAULT_OPTS)
export FZF_DEFAULT_OPTS="--height 100% --color=${_theme_fzf_colors}"
unset _theme_fzf_colors

# atuin (Ctrl-R), Markdown rendering by gh and glow (glamour), ripgrep and jq.
# jq colours are 256-colour codes, nearest to Catppuccin: macOS /usr/bin/jq (1.7.1, called by mas) rejects
# 24-bit codes with "Failed to set $JQ_COLORS".
export ATUIN_THEME__NAME="catppuccin-${THEME_FLAVOR}-mauve"
export GLAMOUR_STYLE="${XDG_CONFIG_HOME}/glamour/catppuccin-${THEME_FLAVOR}.json"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/${THEME_FLAVOR}.rc"
export JQ_COLORS="${_theme_jq_colors}"
unset _theme_jq_colors

# ls colours for completion lists and any tool that reads LS_COLORS
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate catppuccin-${THEME_FLAVOR})"
fi

# zsh-syntax-highlighting (read when the plugin loads)
source "${ZDOTDIR:-${XDG_CONFIG_HOME}/zsh}/themes/catppuccin_${THEME_FLAVOR}-zsh-syntax-highlighting.zsh"
