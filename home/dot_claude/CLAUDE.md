# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code.

## Behavior

1. Don't assume. Don't hide confusion. Surface tradeoffs
2. Minimum code that solves the problem. Nothing speculative
3. Touch only what you must. Clean up only your own mess
4. Define success criteria. Loop until verified

## Language Standards

- **All English**: Code, comments, documentation, commits, configs, errors, tests

## About me

- Name: Raph
- GitHub username: rlemaitre

## PR Workflow

- When creating PRs, organize work into logical separate commits BEFORE opening
  the PR (don't squash everything into one commit)
- PR descriptions must cover the entire branch diff, not just the latest commit
- Never force-push; let the user push manually when force-push is needed
- Assign PRs to me (`gh pr create --assignee @me`) in my personal repositories (owner `rlemaitre`), in repositories of my `FunktionalIO` organization and in `nabla/health`

## Code Review Scope

When reviewing a branch, review the FULL diff against the base branch (not just
recent commits or a sampled subset of files); explicitly enumerate all changed
files first

## Code Intelligence

Prefer LSP over Grep/Glob/Read to understand code: it gives exact results, Grep gives text matches.

- `goToDefinition` / `goToImplementation`, `findReferences`, `workspaceSymbol`, `documentSymbol`, `hover`,
  `incomingCalls` / `outgoingCalls`
- Before renaming or changing a function signature, run `findReferences` to find every call site.
- Use Grep/Glob for discovery (finding files, comments, strings, config values); then navigate inside a file with LSP
  instead of reading it whole.
- After writing or editing code, check LSP diagnostics and fix type errors or missing imports immediately.

## Dotfiles

This Mac's configuration is managed by chezmoi. Find the repo with `chezmoi source-path` (its location differs per Mac; the source is the `home/` folder, so the repo root is its parent).

- Do not edit managed files in `~` and leave them: edit the repo, or edit the live file and run `chezmoi re-add <file>`.
- Before adding or removing a tool, changing a config or a macOS setting, or adding a machine, use the `dotfiles` skill. It points to `docs/maintenance.md` in the repo.
- Install channel order: mise, Homebrew formula, cask, `mas`. A tool lives in one channel only.
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

## Showing Markdown files

When asking me to read a Markdown file (a plan, a spec, a report), open it for me with
`~/.claude/glow-split.sh <file.md>`: it shows the file with `glow --pager` in a Ghostty split next to this pane, and
reuses the split it opened before when that one is still open. Then give the path in the reply as usual.
Only in Ghostty: the script checks that Claude Code runs inside Ghostty and exits with code 3 otherwise (another
terminal, an IDE). On exit code 3, just give the path.
