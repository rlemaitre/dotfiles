#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten cwd: replace $HOME with ~
short_cwd="${cwd/#$HOME/~}"

# Get git branch, skipping optional locks
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Build the status line parts
user_dir="$(whoami) $short_cwd"

if [ -n "$branch" ]; then
    user_dir="$user_dir ($branch)"
fi

line="$user_dir"

if [ -n "$model" ]; then
    line="$line | $model"
fi

if [ -n "$remaining" ]; then
    printf "%s | %d%% remaining" "$line" "$remaining"
else
    printf "%s" "$line"
fi
