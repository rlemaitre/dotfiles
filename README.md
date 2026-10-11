# dotfiles

macOS dotfiles for `athena` and `nabla-mac-raphael`, managed with [chezmoi](https://www.chezmoi.io).

## Fresh Mac

```sh
curl -fsSL https://raw.githubusercontent.com/rlemaitre/dotfiles/main/install.sh | bash
```

Installs Xcode CLT, Homebrew and mise, then runs `chezmoi init --apply`. It asks for the git email once.
Non-interactive: `chezmoi init --apply --promptString "Git email for this machine=you@example.com" <url>`.

## Install policy

1. mise (registry, then `npm:`, `pipx:`, `go:`, `github:` backends)
2. brew formulae
3. brew casks
4. mas

Packages live in `home/.chezmoidata/packages.yaml`, with `common` plus one section per machine.
A tool appears in exactly one channel.

## Layout

- `home/`: chezmoi source directory (set by `.chezmoiroot`)
- `home/.chezmoiscripts/`: `brew bundle`, `mise install`, `mas`; each re-runs only when its rendered content changes
- `scripts/`, `tests/`: repo checks and per-machine test data

## Develop

```sh
mise run check              # shellcheck, shfmt, duplicate check, render templates for every machine
mise run render athena      # print the rendered scripts for one machine
chezmoi --source . diff     # preview changes on this machine
```

## Adding a machine

1. Add its hostname to `home/.chezmoi.toml.tmpl`
2. Add a section for it in every block of `packages.yaml`
3. Add `tests/<hostname>.toml`
