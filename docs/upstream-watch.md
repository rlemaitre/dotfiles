# Upstream watch

Workarounds in this repo that should go away when upstream is fixed. Each section says how to check and how to
switch back.

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

## Claude Code inline images in Rex

**Problem.** Claude Code 2.1.311 draws inline images only when the terminal answers the kitty graphics query and its
XTVERSION name is on a hard-coded list (`kitty` 0.28.0 or later, `ghostty`): the reply alone cannot show support for
the Unicode placeholders it draws with. Rex supports them (checked on 2026-11-28 with Rex 0.1.0-preview.25) but is not
on the list. Reported with `/bug`.

**Workaround in place.** `home/dot_zshenv` sets `CLAUDE_CODE_FORCE_TERMINAL_IMAGES=1` when `TERM_PROGRAM` is `rex`, outside
tmux and GNU screen.

**How to check.** By hand: in Rex, start `env -u CLAUDE_CODE_FORCE_TERMINAL_IMAGES claude` and ask for an image with
the kitty-image plugin's `show_image`. If it draws, the list includes Rex.

**When it is fixed, switch back:**
1. In `dot_zshenv`: delete the `if [[ $TERM_PROGRAM == rex ]]` block and its comment.
2. `chezmoi apply`, then open a new Rex pane.
3. Delete this section.

## mermaid-cli: chromium-bidi trust exemption

**Problem.** `mise install npm:@mermaid-js/mermaid-cli@12.0.0` stops with "trust downgrade for
chromium-bidi@157.0.8090-0": releases up to 10.4.0 were published through npm trusted publishing, this one has no
provenance. Reviewed 2026-10-17: the chromium-bidi source moved into the Chromium repository
(`third_party/chromium-bidi`, see its README), releases now follow Chrome versions and are published by the Google
account `chrome-devtools-npm` (a listed maintainer) from Chromium's infrastructure, and Google's `puppeteer-core`
25.14.0 pins exactly this version. Not verified: the tarball against source (npm records no `gitHead`).

**Workaround in place.** `home/.chezmoidata/packages.yaml`, key `mise_trust_policy_excludes`, exempts only
`chromium-bidi@157.0.8090-0` for mermaid-cli; the mise config template renders it as `trust_policy_excludes`.
`PUPPETEER_EXECUTABLE_PATH` in `home/dot_zshenv` points Puppeteer at the Chrome cask, because mise
skips the postinstall that downloads chrome-headless-shell.

**When mermaid-cli is bumped:** a new puppeteer pulls a new chromium-bidi, which is checked again. If mise refuses it,
review that version the same way and replace the entry; if it installs, delete the entry and this section.

## terminal-browser: agent-browser socket path too long

**Problem.** `terminal-browser action` puts agent-browser sockets in
`$XDG_RUNTIME_DIR/terminal-browser-<id>/agent-browser`. With our `XDG_RUNTIME_DIR` (`~/Library/Caches/TemporaryItems`) the socket path is 114 bytes, over the 103-byte macOS
limit. agent-browser reports it, but terminal-browser only prints "could not connect agent-browser to terminal browser".
Not reported upstream yet ([zenbu-labs/terminal-browser](https://github.com/zenbu-labs/terminal-browser)).

**Workaround in place.** `home/dot_local/bin/executable_terminal-browser` runs the Homebrew binary with
`XDG_RUNTIME_DIR=~/.cache` (about 100 bytes). Unsetting `XDG_RUNTIME_DIR` is not enough: the fallback, `~/.local/state`,
still gives 106 bytes. A script rather than a zsh function, so non-interactive shells (agents, md-show) use it too;
`~/.local/bin` comes before Homebrew in `PATH` for that.

**How to check.** `/opt/homebrew/bin/terminal-browser action -- get title` works with a browser open.

**When it is fixed, switch back:** delete the wrapper script and this section.
