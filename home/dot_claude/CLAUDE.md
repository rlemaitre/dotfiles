# CLAUDE.md

kaizen (plugin kaizen@rlemaitre) carries the general rules; this file holds what is personal or specific to this Mac.

## About me

- Name: Raph
- GitHub username: rlemaitre

## PRs

- Assign PRs to me (`gh pr create --assignee @me`) in my personal repositories (owner `rlemaitre`), in repositories of my `FunktionalIO` organization and in `nabla/health`

## IntelliJ files

IntelliJ rewrites tracked `.idea/` files on its own. Stage files by path, never with `git add -A`, `git add .` or
`git commit -a`. Never stage, revert or stash `.idea/` changes you did not make in this session, unless I ask for it.
The intellij plugin's idea-guard hook blocks such a commit; a prompt of mine that mentions `.idea` lifts the block for
the session.

## Dotfiles

This Mac's configuration is managed by chezmoi. Find the repo with `chezmoi source-path` (its location differs per Mac; the source is the `home/` folder, so the repo root is its parent).

- Do not edit managed files in `~` and leave them: edit the repo, or edit the live file and run `chezmoi re-add <file>`.
- Before adding or removing a tool, changing a config or a macOS setting, or adding a machine, use the `dotfiles` skill. It points to `docs/maintenance.md` in the repo.
- Install channel order: mise, Homebrew formula, cask, `mas`. A tool lives in one channel only.
- Slidev comes from mise (`npm:@slidev/cli` in the package data). Never install or update it globally with npm, pnpm or yarn,
  including through the slidev plugin's `install-slidev.sh`: bump the pin in the repo instead.
- Run `mise run check` in the repo before every commit. Never push without asking.
- Machine differences go in the `athena` / `nabla-mac-raphael` data sections or in templates, never in copied files.
- The repo is public: no secrets, tokens or private data in it.

## Productivity plugin

The productivity plugin keeps its data in `~/Developer/workspace/02_context/productivity/`. The workspace git-ignores that
folder, so each Mac has its own copy and nothing is synced.

- From any working directory, read and write `TASKS.md`, the hot cache `CLAUDE.md`, `memory/` and `dashboard.html` in that
  folder. Never create them in the current project or at the workspace root.
- Read the hot cache there when a request mentions tasks, people, projects or internal terms you do not know.
- If the folder is missing, create it, then run `/productivity:start` and place its files there.
