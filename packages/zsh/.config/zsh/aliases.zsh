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
  git rm  2> /dev/null
  git commit --no-verify --no-gpg-sign --message '--wip-- [skip ci]' $argv
}

function sync() {
  source $ZDOTDIR/.zshrc
}

alias vim="nvim"

alias ls="eza --git --git-repos --color=always --color-scale=all --color-scale-mode=gradient --all --icons always --smart-group --group-directories-first --hyperlink --modified --classify=always";
alias ll="ls --long";
alias l="ll --no-user --no-permissions --octal-permissions --time-style=relative";
alias cat="bat";
alias grep="rg";
alias diff="delta";
alias top="gotop";
alias pinentry='pinentry-mac'

# fix fast typing
alias brwe="brew"
