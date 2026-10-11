---
name: dotfiles
description: Use when changing this Mac's setup, which is managed by chezmoi in a dotfiles repo - adding or removing a tool, app or Homebrew/mise package, editing a managed config file, changing a macOS setting, adding a machine, updating tools, or fixing "has changed since chezmoi last wrote it".
---

# Dotfiles

Machines: `athena` (personal), `nabla-mac-raphael` (work). Same repo, per-machine data and templates.

## 1. Locate and read

1. `REPO="$(dirname "$(chezmoi source-path)")"` (the source is `$REPO/home`).
2. Read `$REPO/docs/maintenance.md` and follow the recipe that matches the request. Background is in `$REPO/docs/how-it-works.md`; installed tools in `$REPO/docs/tools.md` (generated, never edit).

## 2. Rules

- Channel order: mise, formula, cask, `mas`. One channel per tool. What is installed is declared in `home/.chezmoidata/packages.yaml` (`common`, `athena`, `nabla-mac-raphael`); a new entry also needs a line in `docs/tool-descriptions.yaml`, then `mise run docs`.
- Never edit a managed file in `~` and stop there: change the repo file, or run `chezmoi re-add <file>` after a live edit. Files an app rewrites are `create_` seeds.
- Installing never removes anything; uninstall by hand and delete the entry from the data.
- macOS settings: `home/.chezmoidata/macos_defaults.yaml`.
- Per-machine differences: data sections or templates, never copied files.
- No secrets; the repo is public. Read a file before `chezmoi add`.

## 3. Verify and finish

1. `chezmoi diff` to preview, then `chezmoi apply` only if the user wants it applied now.
2. `mise run check` must pass (lint, rendering for both machines, tools list, links).
3. Commit as `<type>: <description>` only when asked. Never push without asking.
4. A workaround for an upstream bug is tracked in `docs/upstream-watch.md`; a manual install in `docs/manual-installs.md`.
