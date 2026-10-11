# dotfiles

Configuration and software setup for two MacBook Pros: **athena** (personal) and **nabla-mac-raphael**
(work). One repository describes what is installed, how it is configured and how macOS is set up, so a
fresh Mac reaches the working setup with one command and an existing Mac stays in sync with `chezmoi apply`.

| Part | Tool | Role |
|---|---|---|
| Config files and scripts | [chezmoi](https://www.chezmoi.io) | Copies files into `~`, renders per-machine templates, runs setup scripts |
| Command-line tools and runtimes | [mise](https://mise.jdx.dev) | First choice for every tool it can install |
| Everything else | Homebrew (formulae, casks), `mas` (App Store) | Used when mise cannot install it |
| Theme | Catppuccin, Latte (light) and Mocha (dark) | Follows the macOS appearance, see [themes](docs/themes.md) |

## Set up a new Mac

1. Name the Mac `athena` or `nabla-mac-raphael` (System Settings, General, About). Any other hostname makes
   `chezmoi init` stop with "unknown host": see [add a machine](docs/maintenance.md#add-a-machine).
2. Sign in to the App Store (needed by `mas`).
3. Run:

   ```sh
   curl -fsSL https://raw.githubusercontent.com/rlemaitre/dotfiles/main/install.sh | bash
   ```

`install.sh` installs the Xcode Command Line Tools, Homebrew and mise, then runs `chezmoi init --apply`,
which asks three questions (git email, SSH key file name in `~/.ssh`, GPG signing key id), applies every file and
runs the setup scripts in order. Enter accepts the suggestion shown (athena has real ones, the laptop's are empty);
an empty answer means none. It is safe to run again. Expect:

- your password several times (Homebrew, Touch ID for `sudo`, vendor installers), and a long first run
  (dozens of apps; the [tools list](docs/tools.md) shows which go on which Mac);
- `gh auth login`, then `chezmoi apply` once more: GitHub extensions, agent skills and the clone of the private workspace repository (`~/Developer/workspace`) wait for a logged-in `gh`;
- a reboot if DisplayLink or Logitech Options+ got installed;
- the apps in [manual installs](docs/manual-installs.md).

Then open a new terminal.

## Everyday commands

| I want to | Command |
|---|---|
| See what would change in `~` | `chezmoi diff` |
| Apply the repo to this Mac | `chezmoi apply` |
| See which managed files differ | `chezmoi status` |
| Save a live edit back into the repo | `chezmoi re-add <file>` |
| Start managing a file | `chezmoi add <file>` |
| Edit a managed file through the repo | `chezmoi edit <file>` |
| Validate everything before committing | `mise run check` |
| Print the scripts rendered for one machine | `mise run render athena` |
| Regenerate the tools list | `mise run docs` |
| Check whether a workaround can go | `mise run upstream-check` |
| Bump pinned versions | `mise run bump-pins` (a weekly pull request does it too) |
| List what is installed on a Mac | `scripts/inventory.sh` |
| See what needs attention (drift, outdated, undeclared) | `scripts/maintain.sh --report-only` (a weekly agent does it too) |

More in [maintenance](docs/maintenance.md).

## Repository layout

```text
.
├── install.sh                 bootstrap for a fresh Mac
├── mise.toml                  repo tasks: check, render, docs, bump-pins, upstream-check
├── .chezmoiroot               makes home/ the chezmoi source directory
├── home/                      what chezmoi manages (a mirror of ~)
│   ├── .chezmoi.toml.tmpl     per-machine questions and data
│   ├── .chezmoidata/          packages.yaml (what to install), macos_defaults.yaml (macOS settings)
│   ├── .chezmoiscripts/       setup scripts, run by chezmoi in numeric order
│   ├── .chezmoiremove         files chezmoi deletes
│   ├── dot_config/            ~/.config (zsh, git, nvim, ghostty, zed, lazygit, ...)
│   ├── dot_claude/            ~/.claude (global instructions, rules, agents, commands, the dotfiles skill, a settings seed)
│   ├── private_dot_ssh/, private_dot_gnupg/, private_Library/   modes 700 or 600
│   └── dot_zshenv, dot_better-commits.json
├── scripts/                   check-*.sh/py, bump-pins.py, gen-tools-doc.py, maintain.sh, inventory.sh
├── tests/                     fixture data per machine, used by `mise run check`
├── docs/                      the documentation below
└── .github/workflows/         weekly upstream-watch and bump-pins jobs
```

## Documentation

- [How it works](docs/how-it-works.md): install policy, chezmoi naming, per-machine data, the setup scripts, the shell
- [Maintenance](docs/maintenance.md): add or remove a tool, add a machine, update, drift, troubleshooting, rollback
- [Tools](docs/tools.md): everything installed, with a description (generated)
- [Themes](docs/themes.md): how light and dark mode reach each tool
- [Manual installs](docs/manual-installs.md): apps Homebrew cannot install
- [Upstream watch](docs/upstream-watch.md): workarounds to remove when upstream is fixed

## Ground rules

1. A tool is installed through **one channel only**: mise, else a Homebrew formula, else a cask, else the App Store.
2. **No secrets** in the repo: no keys, tokens or registry logins. Files that can hold them are not managed.
3. What is installed is decided in **`home/.chezmoidata/packages.yaml`**. Nothing is installed from a script by hand.
4. Per-machine differences use the `athena` and `nabla-mac-raphael` sections of the data, or templates. Never copy a file.
5. After editing a managed file in place, run `chezmoi re-add <file>`; before committing, run `mise run check`.
