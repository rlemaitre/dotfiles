# Upstream watch

Workarounds in this repo that should go away when upstream is fixed. `mise run upstream-check` runs the
checks by hand; the GitHub Actions workflow `.github/workflows/upstream-watch.yml` runs them every Monday and
opens an issue in this repository when one is fixed (it only runs once the repo is on GitHub, on the default
branch).

## kotlin-lsp (Claude Code's Kotlin language server)

**Problem.** `brew install jetbrains/utils/kotlin-lsp` fails: the formula downloads a `.sit` archive that
answers HTTP 404 on JetBrains' CDN. Upstream: [Kotlin/kotlin-lsp#282](https://github.com/Kotlin/kotlin-lsp/issues/282)
and [JetBrains/homebrew-utils#21](https://github.com/JetBrains/homebrew-utils/issues/21). mise has no entry
and the GitHub release has no assets.

**Workaround in place.** `home/.chezmoiscripts/run_onchange_after_45_kotlin-lsp.sh.tmpl` downloads JetBrains'
VS Code extension archive (version, URL and sha256 are in `home/.chezmoidata/packages.yaml`, key `kotlin_lsp`),
extracts the server to `~/.local/share/kotlin-lsp/<version>` and links `~/.local/bin/kotlin-lsp`.

**How the check decides.** `scripts/check-upstream.sh` reads the current formula from the tap, replaces
`#{version}`, and sends a HEAD request to every `url` it declares. All answering 200 means fixed (exit code 10).
It also prints the state of the upstream issue, for information only.

**When it says FIXED, switch back:**
1. In `home/.chezmoidata/packages.yaml`: delete the `kotlin_lsp` block, add `JetBrains/utils` to `brew.taps.common`
   and `jetbrains/utils/kotlin-lsp` to `brew.formulae.common`. The bootstrap taps and trusts the tap itself.
2. Delete `home/.chezmoiscripts/run_onchange_after_45_kotlin-lsp.sh.tmpl`.
3. On each Mac: `rm -rf ~/.local/share/kotlin-lsp ~/.local/bin/kotlin-lsp`, then `chezmoi apply` (brew bundle installs
   the formula).
4. Run `kotlin-lsp --version`, then delete this section and the check (script, workflow job, mise task).

## Claude Code zsh completion

**Problem.** Claude Code ships no shell completion: no `completion` subcommand and no `_claude` file. Upstream:
[anthropics/claude-code#7738](https://github.com/anthropics/claude-code/issues/7738).

**Workaround in place.** `home/dot_config/zsh/dot_zshrc` loads the community completion
[wbingli/zsh-claudecode-completion](https://github.com/wbingli/zsh-claudecode-completion) with zinit, pinned with
`zinit ice ver"<sha>"`. Upstream merges bot-generated updates every day, so the pin only moves after reading the
`_claude` diff (it should stay read-only: no network, no `eval`, no writes).

**How to check.** By hand, no automated check: `claude --help` lists a completion command, or #7738 is closed as fixed.

**When it is fixed, switch back:**
1. In `dot_zshrc`: delete the two `zinit` lines for `wbingli/zsh-claudecode-completion` and their comment.
2. Generate the official completion in `run_onchange_after_47_zsh-completions.sh.tmpl` (`gen claude claude <command>`).
3. On each Mac: `zinit delete wbingli/zsh-claudecode-completion`, `rm ~/.cache/zsh/completions/_claude`, then `chezmoi apply`.
4. Delete this section.
