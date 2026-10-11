#! /usr/bin/env zsh
#
# Aliases
# =======
#
# This file contains all the aliases that are used in the shell. Aliases are
# shortcuts for commands that are used often. For example, instead of typing
# `ls -l` you can just type `ll`. This file is sourced in the `.zshrc` file.
#
# For more information on aliases, check out:
# https://scriptingosx.com/2017/01/about-bash_profile-and-bashrc-on-macos/
# https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions

# General
# -------

function gwip() {
    git add -A
    git rm 2>/dev/null
    git commit --no-verify --no-gpg-sign --message '--wip-- [skip ci]' $argv
}

function sync() {
    source $ZDOTDIR/.zshrc
}

alias vim="nvim"

alias ls="eza --git --git-repos --color=always --color-scale=all --color-scale-mode=gradient --all --icons always --smart-group --group-directories-first --hyperlink --modified --classify=always"
alias ll="ls --long"
alias l="ll --no-user --no-permissions --octal-permissions --time-style=relative"
alias cat="bat"
alias grep="rg"
alias diff="delta"
alias top="gotop"
alias pinentry='pinentry-mac'

# fix fast typing
alias brwe="brew"

# open bookmarks

bookmarks-select() {
    buku --print --format 5 | column -ts$'\t' -c 3 | fzf --multi --reverse --preview "buku --nostdin --print {1}" --preview-window=wrap | cut -w -f1
}
bookmarks-open() {
    local websites=("${(@f)$(bookmarks-select)}")
    for i in "${websites[@]}"; do
        url="$(buku --nostdin --format 10 --print $i)"
        echo "Opening $url"
        open -u "$url"
    done
}

bookmarks-delete() {
    local websites=("${(@f)$(bookmarks-select)}")
    for i in "${websites[@]}"; do
        echo "Deleting $i"
        buku --nostdin --delete $i
    done
}

# glow ignores GLAMOUR_STYLE when its config style is "auto": pass the themed style explicitly.
# A later -s on the command line still wins. (gh reads GLAMOUR_STYLE by itself.)
glow() {
    command glow -s "${GLAMOUR_STYLE:-auto}" "$@"
}

# lazydocker reads its config from CONFIG_DIR: pick the themed one for this call only
# (an exported CONFIG_DIR would leak into every other tool).
lazydocker() {
    CONFIG_DIR="${XDG_CONFIG_HOME}/lazydocker/${THEME_FLAVOR:-latte}" command lazydocker "$@"
}
alias lzd='lazydocker'
