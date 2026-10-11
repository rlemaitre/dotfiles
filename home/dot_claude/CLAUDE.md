# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code.

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:

- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use `findReferences` to find all call sites first.

Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.

When tracing where a symbol is defined or finding all references to it, use LSP (goToDefinition, findReferences, hover) instead of Grep.
LSP gives exact results; Grep gives text matches.

Use Grep/Glob for discovery (finding files, searching patterns). Use LSP for understanding (definitions, references, type info).

After locating a file with Grep/Glob, use LSP to navigate within it rather than reading the whole file.

## Dotfiles

This Mac's configuration is managed by chezmoi. Find the repo with `chezmoi source-path` (its location differs per Mac; the source is the `home/` folder, so the repo root is its parent).

- Do not edit managed files in `~` and leave them: edit the repo, or edit the live file and run `chezmoi re-add <file>`.
- Before adding or removing a tool, changing a config or a macOS setting, or adding a machine, use the `dotfiles` skill. It points to `docs/maintenance.md` in the repo.
- Install channel order: mise, Homebrew formula, cask, `mas`. A tool lives in one channel only.
- Run `mise run check` in the repo before every commit. Never push without asking.
- Machine differences go in the `athena` / `nabla-mac-raphael` data sections or in templates, never in copied files.
- The repo is public: no secrets, tokens or private data in it.
