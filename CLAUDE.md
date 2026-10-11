# dotfiles

Personal macOS dotfiles, rewritten from scratch.

## Install policy (priority order)

1. CLI tools and runtimes: mise (registry first, then `npm:`, `pipx:`, `go:`, `github:` backends)
2. CLI tools mise cannot install: brew formulae
3. GUI apps: brew casks
4. GUI apps without a cask: `mas`

Never install the same tool through two channels.

## Machines

- `athena`: personal Mac
- `nabla-mac-raphael`: professional laptop (same hardware as athena, different SSH keys, same GitHub user)
- Shared base config plus per-machine overrides. Brewfiles: shared + one per machine, installed with `brew bundle`.

## Rules

- Bootstrap scripts must be idempotent.
- Config is managed by chezmoi. Source dir is `home/` (via `.chezmoiroot`). Per-machine differences use templates, never copies.
- Package lists use plain `brew bundle`, not `brew-file`.
- No secrets in the repo.
- Shell: `mise activate zsh` must run before any line that calls a mise-installed tool.
