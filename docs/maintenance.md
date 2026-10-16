# Maintenance

How to change, update and repair this setup. Background is in [how it works](how-it-works.md).

## The loop

1. Edit the repo (data file, config file or script).
2. `chezmoi diff`: see exactly what would change in `~`.
3. `chezmoi apply`: files first, then the setup scripts.
4. `mise run check`: lint, duplicate check, render every template for both machines, tools list up to date.
5. Commit.

`chezmoi apply --dry-run --verbose` shows the plan without touching anything. `chezmoi apply --exclude=scripts`
applies files only. A single target: `chezmoi apply ~/.config/mise/config.toml`.

What `mise run check` does: `shellcheck` on every shell script (the rendered setup scripts included) and `shfmt` on the
plain ones, `zsh -n` on zsh files, `git config --list` on the rendered git config, `plutil -lint` on the rendered
plist, `scripts/check-packages.sh` (no tool in two channels), `scripts/gen-tools-doc.py --check` (every tool has a
description and `docs/tools.md` is current), `scripts/check-links.py` (links and anchors in the docs resolve). It never installs anything.

## Recipes

### Add a tool

1. Pick the channel: mise first, then formula, cask, App Store ([policy](how-it-works.md#install-policy)).
2. Add it to the right list in `home/.chezmoidata/packages.yaml`: `common` for both Macs, or `athena` or
   `nabla-mac-raphael`. A mise entry must be pinned, `name@version` (`mise latest <name>` prints the version;
   `mise run check` fails without it). App Store apps are `"id": "Name"`
   (`mas search <name>` finds the id). A tool from a third-party tap needs the tap in `brew.taps` too.
3. Add one line for it in `docs/tool-descriptions.yaml`, then `mise run docs`.
4. `chezmoi apply`, then `mise run check`.

Installing never removes anything: see [remove a tool](#remove-a-tool).

If the app is already installed by hand, `brew install --cask --adopt <cask>` takes it over only when the installed
version equals the cask's. Otherwise `brew install --cask --force <cask>` replaces it (close the app first); casks
that run a vendor installer (DisplayLink, Logitech) need your password and a terminal.

### Remove a tool

1. Delete it from `packages.yaml` and from `docs/tool-descriptions.yaml`, then `mise run docs`.
2. Uninstall it yourself, because chezmoi and `brew bundle` never uninstall:
   `mise uninstall --all <tool>`, `brew uninstall [--cask] <name>`, `mas uninstall <id>` (moves the app to the Trash).
3. Delete leftovers by hand (`~/.config/<tool>`, `~/Library/...`). If a managed file must also disappear from
   every Mac, add its path to `home/.chezmoiremove`.

`brew uninstall` also removes dependencies that were not installed on request. A tool you want to keep must be listed in
`packages.yaml`, otherwise uninstalling something that depended on it takes it away too.

### Move an app between Macs

Move its entry between `common`, `athena` and `nabla-mac-raphael` in `packages.yaml`. Nothing is uninstalled on a Mac
that no longer lists it.

### Manage a config file

```sh
chezmoi add ~/.config/foo/config        # copies it into home/dot_config/foo/config
chezmoi add --template ~/.gitconfig     # when it must differ per machine, then replace values with {{ .email }} etc.
```

- Look for secrets first (`grep -iE 'token|secret|password|api[_-]?key' <file>`). If a file can hold credentials, do not add it.
- A file only one Mac needs: wrap its path in `home/.chezmoiignore` with `{{ if ne .machine "athena" }}`, or branch inside a template.
- A file an app rewrites itself: rename its source to `create_<name>` (created once, never overwritten), or keep it
  managed and run `chezmoi re-add` after in-app changes.
- Check what the files look like on each machine: `mise run render nabla-mac-raphael`, or
  `chezmoi --config tests/nabla-mac-raphael.toml --source . execute-template < <template>`.

### Change a macOS setting

1. Find the key: run `defaults read > /tmp/before`, change the setting in System Settings, run `defaults read > /tmp/after`,
   `diff` the two (also `defaults -currentHost read` for per-host keys).
2. Add `{domain, key, type, value}` to `macos_defaults.yaml` (`host: true` for `-currentHost`). Types are `bool`,
   `int`, `float`, `string`, and `dict` of booleans.
3. To undo a setting an older script made, add `{domain, key}` to `macos_defaults_absent`.
4. `chezmoi apply` runs script 70, which restarts the Dock, Finder and menu bar (a brief flicker).

Power settings (`pmset`) are in `macos_power`; they need `sudo` and therefore a terminal.

### Add a machine

1. Set the hostname on the Mac (System Settings, General, About).
2. In `home/.chezmoi.toml.tmpl` add the hostname to `$knownHosts` and its suggested answers to `$defaults`.
3. Add the new key (empty is fine) to every section of `packages.yaml` and `macos_defaults.yaml`.
4. Copy `tests/nabla-mac-raphael.toml` to `tests/<hostname>.toml` and change `machine`.
5. `mise run check`, commit and push, then run `install.sh` on the new Mac ([README](../README.md#set-up-a-new-mac)).
6. To fill its package lists: `scripts/inventory.sh > inventory.md` on that Mac lists what is installed, and comparing it with
   the other Mac's output shows which entries belong in `common`.

### Add a Quick Look extension, a GitHub extension or an agent skill

Add the entry to `quicklook_extensions`, `gh_extensions` or `gh_skills` in `packages.yaml` and a description in
`docs/tool-descriptions.yaml`. Read a skill before adding it: it is instructions an agent will follow.

## Updating

| What | How |
|---|---|
| mise tools | Every entry is pinned: the weekly pull request bumps them (below), or run `mise run bump-pins` now. `mise upgrade` does nothing for them. A new major version: change the pin by hand. |
| Homebrew | formulae: the [weekly upkeep](#weekly-upkeep-on-each-mac) upgrades them. Casks: `brew upgrade --cask <name>` (close the app first); the report lists the outdated ones. `brew bundle` itself never upgrades (`--no-upgrade`). |
| GitHub CLI extensions | pinned too: the weekly pull request bumps `pin` in `gh_extensions`, `chezmoi apply` reinstalls at the new tag |
| Agent skills | the weekly pull request bumps `pin` in `gh_skills`; then delete `~/.claude/skills/<skill>` and `chezmoi apply` |
| Neovim plugins | `:Lazy update`, then `chezmoi re-add ~/.config/nvim/lazy-lock.json ~/.config/nvim/lazyvim.json` |
| Neovim tools | `:Mason`, then `U` (updates the language servers and formatters Mason installed) |
| Colima | edits to the template apply to new instances only: `colima delete` then `colima start` |
| Catppuccin theme files | see [themes](themes.md#changing-things) |
| kotlin-lsp | bump `kotlin_lsp` in `packages.yaml` (version, URL, sha256) while the stopgap exists |
| Upstream workarounds | `mise run upstream-check`; a weekly GitHub Actions job opens an issue when one is fixed |

### Automatic pin bumps

Every mise tool, `gh` extension and agent skill is pinned in `packages.yaml`, so both Macs run the same versions and
nothing changes unless the repo does. `.github/workflows/bump-pins.yml` runs every Monday (or by hand: Actions,
bump-pins, Run workflow) and runs `scripts/bump-pins.py`:

- a newer release in the same **line** is applied: the major version (`pnpm@10.8.1` follows 10.x.y), or major.minor for
  `python` and for 0.x versions, because a 0.x minor may break;
- a newer line is **only listed** in the pull request ("not applied"): read the changelog, then change the pin by hand;
- it regenerates `docs/tools.md` and keeps one pull request, `chore/bump-pins`, up to date. No pull request when
  nothing can be applied. `kotlin_lsp` is not touched, and Homebrew formulae and casks cannot be pinned (`brew upgrade`).

To merge: `gh pr checkout <number> && mise run check`, merge, then `chezmoi update` on each Mac (`chezmoi apply` alone
does not pull); the mise install script re-runs because the tool list changed. Pull requests opened by Actions do not
start other workflows, so the check is yours to run. One-time setting: repository Settings, Actions, General, enable
"Allow GitHub Actions to create and approve pull requests". To bump by hand: `mise run bump-pins`
(`--dry-run` only prints).

## Weekly upkeep on each Mac

The LaunchAgent `com.rlemaitre.maintain` runs `scripts/maintain.sh` on Sundays at 10:15, or when the Mac wakes up if it
slept then (installed by script 85; the log is `~/Library/Logs/dotfiles/maintain.log`).

1. **Upgrades**: `brew update`, `brew upgrade --formula`, `brew cleanup`, `mise prune` (old versions after a pin
   bump). Casks, App Store apps and pinned mise tools are never touched: they change through you or the repo.
   `mise prune` also removes any tool version that no config file lists (a `mise use` tried by hand, a project
   that was deleted): list a tool in `packages.yaml` or in the project's `mise.toml` to keep it.
2. **Report**: `~/Library/Logs/dotfiles/report.md`, with a macOS notification when something needs attention:
   the repo is behind GitHub or has unpushed or uncommitted changes, a bump pull request is open, managed files differ
   from the repo, packages installed but not in `packages.yaml` (and the reverse), outdated casks, and the kotlin-lsp
   check from [upstream watch](upstream-watch.md). Each section says what to run.

By hand: `scripts/maintain.sh --report-only` prints the report and changes nothing; `scripts/maintain.sh` also upgrades.
`launchctl kickstart gui/$(id -u)/com.rlemaitre.maintain` runs the agent now. To stop it: `launchctl bootout
gui/$(id -u)/com.rlemaitre.maintain`, and remove the script and plist from the repo.

## Standup brief (work Mac)

The LaunchAgent `com.rlemaitre.standup-brief` runs `bin/standup-brief` from the private repo `rlemaitre/standup-brief`
(cloned in `~/Developer/workspace/03_projects/standup-brief/repo`) Monday to Friday at 09:30, or when the Mac wakes up
if it slept then (installed by script 86, only on `nabla-mac-raphael`). It fills the Notion journal and, on standup
days, sends a Slack DM; a cloud routine does it at 09:40 when the Mac was asleep. Logs:
`~/Library/Logs/standup-brief.log` and `~/Library/Logs/standup-brief.launchd.log`.

`launchctl kickstart gui/$(id -u)/com.rlemaitre.standup-brief` runs it now. To stop it: `launchctl bootout
gui/$(id -u)/com.rlemaitre.standup-brief`, and remove the script and plist from the repo.

## Drift and conflicts

chezmoi refuses to overwrite a managed file that changed since it last wrote it:

```text
.config/zed/settings.json has changed since chezmoi last wrote it?
chezmoi: ... could not open a new TTY
```

That is not an error in your setup; it protects your edit. Look first: `chezmoi diff <file>`.

- Keep the live version: `chezmoi re-add <file>`, then commit. For a template (`chezmoi source-path <file>` ends in
  `.tmpl`, like Zed's `settings.json`), `re-add` does nothing: `chezmoi merge <file>` and copy the change into the source.
- Take the repo version: `chezmoi apply --force <file>`.

Without a terminal (scripts, an agent) the question cannot be asked and the apply stops. `chezmoi status` lists the files
that differ (`M` modified, `A` would be added, `D` would be deleted, `R` a script that would run).

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `chezmoi init` stops with "unknown host" | The hostname is not in `$knownHosts`: [add a machine](#add-a-machine). |
| A setup script did not run after a data change | `onchange` scripts rerun only when their rendered text changes, so a script must embed the data it depends on (a tool list, a hash of a file it uses). To force every `onchange` script: `chezmoi state delete-bucket --bucket=scriptState`. |
| A new tool is "command not found" in a script or an agent | mise activation lives in `.zshrc`; non-interactive shells only have the shims in `~/.local/share/mise/shims`. Use `mise exec <tool> -- <command>`. |
| A tool has no tab completion | Completions of mise tools are generated by script 47. Add the tool's completion command there, or check `(( $+_comps[tool] ))`. |
| Colors do not follow dark mode in one tool | Tools in the "chosen when a shell starts" group need a new shell after the appearance changes ([themes](themes.md)). |
| Testing a tool's output shows no styling | Most tools drop styling when output is piped. Test on a pseudo-terminal or force colors (`--color=always`, `CLICOLOR_FORCE=1`). |
| `oh-my-posh --config` ignores the file | A `POSH_CONFIG` variable inherited from a running prompt overrides the flag: `env -u POSH_CONFIG ...`. |
| `~/Library` became world-readable | Its source directory must be `private_Library` (mode 700). |
| Colima keeps editing `~/.ssh/config` | `sshConfig: false` in the Colima template and in `~/.config/colima/default/colima.yaml`. |
| `Could not write domain com.apple.universalaccess` | The domain is privacy-protected. Give the terminal app Full Disk Access (System Settings, Privacy & Security), restart it, then `chezmoi apply`. Entries marked `protected: true` only warn. |
| Homebrew warns that a tap is not trusted | Taps listed in `packages.yaml` are trusted by script 10. For another one: `brew trust --tap <name>`. |
| A cask install fails because the app exists | [Adopt or replace it](#add-a-tool). |
| A dotfolder of an uninstalled tool remains | Uninstalling does not delete app data: delete it by hand ([remove a tool](#remove-a-tool)). |

## Conventions

- File names are lowercase with hyphens between words (`README.md`, `CLAUDE.md` and `LICENSE` excepted).
- Commit messages: `<type>: <description>` with `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf` or `ci`, and a body that
  says why. One logical change per commit; run `mise run check` first.
- Secrets never enter a commit. Before committing a new file, read it.
- `docs/tools.md` is generated: edit `docs/tool-descriptions.yaml`, not the table.
- Keep a workaround's removal steps in [upstream watch](upstream-watch.md) and a manual install in [manual installs](manual-installs.md).

## Publishing and rollback

- `main` is the branch machines install from (`install.sh` clones it over HTTPS; the repo is public, so
  everything in it, including the package lists, is public).
- The history before the rewrite is the branch `backup/pre-rewrite-2026-10-11`.
- To undo a change: `git revert <commit>` and `chezmoi apply`. A file removed through `.chezmoiremove` is not restored by
  that; take it from git history or a backup.
- The weekly jobs `upstream-watch.yml` (issues) and `bump-pins.yml` (a pull request) never push to `main`; nothing deploys from CI.

## Claude on each Mac

`~/.claude/CLAUDE.md` (from `home/dot_claude/CLAUDE.md`) tells Claude Code that the Mac is managed by chezmoi and sets the
short rules. The `dotfiles` skill (`home/dot_claude/skills/dotfiles/`) loads on requests that change the setup and points
Claude to this page. `home/dot_claude/agents/` and `commands/` hold the sub-agents (`architect`, `security-reviewer`,
`build-error-resolver`...) and slash commands that the rules in `home/dot_claude/rules/` refer to (planning, TDD and code review come from the
superpowers plugin, so those agents and commands are gone); the status line is
`statusline-command.sh`, wired by the `statusLine` key of the settings seed. A command or agent that needs a tool this
setup lacks is deleted from the repo and listed in `.chezmoiremove`, so chezmoi removes it from every Mac. Plugins (LSP servers, worktrunk, i-have-adhd, superpowers, productivity, security-guidance, obsidian, frontend-design) are listed in `enabledPlugins` of the same seed; the seed is
only created on a new Mac, so add a plugin there and run `claude plugin install <name>@<marketplace>` on the others (`claude plugin marketplace add <owner/repo>` first
for a marketplace that is not built in).
`security-guidance` reviews the diff with the newest Opus when a turn ends and builds a Python venv in
`~/.claude/security/` (not managed by chezmoi); the settings `env` pins both reviews (`SECURITY_REVIEW_MODEL`, `SG_AGENTIC_MODEL`) to `claude-sonnet-5-5` to save
tokens; change the id there when a newer Sonnet should take over.
Other skills in `~/.claude/skills` (from `gh_skills`) are not touched by chezmoi.
caveman is installed by hand, not from the seed; `~/.config/caveman/config.json` sets its default level to `lite`, which keeps
full sentences and so reads well with `/i-have-adhd` (wording from caveman, structure from i-have-adhd). Both stop on
"normal mode"; say "stop caveman" or "stop adhd mode" to turn off only one.
i-have-adhd is always on: the SessionStart hook `~/.claude/hooks/i-have-adhd.sh` prints the newest installed `SKILL.md` into
every session. The hook is in the settings seed, and script 90 adds it to a `settings.json` that already exists. To turn it
off for one session, say "stop adhd mode"; to remove it, delete the hook from both and from the live settings.
