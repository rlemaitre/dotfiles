# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code.

## Behavior

1. Don’t assume. Don’t hide confusion. Surface tradeoffs
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
