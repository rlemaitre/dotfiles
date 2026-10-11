# Themes

One palette everywhere: **Catppuccin**, accent **mauve**. **Latte** when macOS is light, **Mocha** when it is dark.

## How each tool follows the system

| Tool | Mechanism |
|---|---|
| Ghostty | `theme = light:Catppuccin Latte,dark:Catppuccin Mocha` (built-in themes, follows the system live) |
| Zed | `theme` and `icon_theme` with `mode: system` (Catppuccin extensions) |
| Neovim | catppuccin with `flavour = "auto"`; Neovim takes `background` from the terminal, so it follows Ghostty |
| bat | `--theme=auto:system` with `--theme-light`/`--theme-dark` (live); `BAT_THEME` from `theme.zsh` when set |
| Xcode | separate light and dark themes in `XCFontAndColorCurrentTheme` / `XCFontAndColorCurrentDarkTheme` (macOS defaults data) |
| atuin (Ctrl-R), gh and glow (Markdown via glamour), ripgrep, jq, man pages, lazydocker, delta, fzf, eza, lazygit, gh-dash, vivid (`LS_COLORS`), zsh-syntax-highlighting, oh-my-posh | chosen **when a shell starts** by `home/dot_config/zsh/theme.zsh` from `defaults read -g AppleInterfaceStyle` |

After changing the macOS appearance, open a new shell for the second group. Force a mode with `THEME_MODE=dark zsh`.

`theme.zsh` exports `THEME_MODE`, `THEME_FLAVOR` (latte/mocha), `BAT_THEME`, `DELTA_FEATURES`, `EZA_CONFIG_DIR`, `LG_CONFIG_FILE`, `GH_DASH_CONFIG`, `FZF_DEFAULT_OPTS`, `LS_COLORS`, `ATUIN_THEME__NAME`, `GLAMOUR_STYLE`, `RIPGREP_CONFIG_PATH` and `JQ_COLORS`. oh-my-posh reads `THEME_FLAVOR` through the `palettes` template in `catppuccin.omp.json`.

## Vendored files (MIT, from github.com/catppuccin)

| File | Source |
|---|---|
| `bat/themes/Catppuccin {Latte,Mocha}.tmTheme` | catppuccin/bat @ 6810349 (2025-06-29) |
| `eza/{latte,mocha}/theme.yml` | catppuccin/eza @ 70f805f (2025-09-03), `catppuccin-*-mauve.yml` |
| `lazygit/themes/catppuccin-{latte,mocha}.yml` | catppuccin/lazygit @ 1a4b26c (2026-10-10), `themes-mergable/*/mauve.yml` (the plain `themes/` variant has no `gui:` key and is ignored when merged) |
| `gh-dash/{latte,mocha}.yml` | catppuccin/gh-dash @ ecd62f5 2026-04-14, `catppuccin-*-mauve.yml` |
| `delta/catppuccin.gitconfig`, `zsh/themes/*`, Xcode `*.xccolortheme`, fzf colours in `theme.zsh` | carried over from the previous dotfiles repo (Catppuccin ports), Latte and Mocha only |

| `atuin/themes/catppuccin-{latte,mocha}-mauve.toml` | catppuccin/atuin @ 68aa64b 2026-03-02 |
| `glamour/catppuccin-{latte,mocha}.json` | catppuccin/glamour @ 00c97fa 2025-05-02 |
| `ripgrep/{latte,mocha}.rc`, `JQ_COLORS` in `theme.zsh` | written from the Catppuccin palette (no upstream port) |

oh-my-posh: `catppuccin.omp.json` keeps the previous prompt layout (from `nord.json`); only the colours moved into a Latte/Mocha palette.

## Notes per tool

- **glow** ignores `GLAMOUR_STYLE` when its config style is `auto`, so `aliases.zsh` wraps it: `glow() { command glow -s "$GLAMOUR_STYLE" "$@" }`. **gh** reads `GLAMOUR_STYLE` itself.
- **atuin** reads `ATUIN_THEME__NAME` over `config.toml`; the config in the repo is minimal (the generated 289-line default was not kept).
- **man pages** go through bat (`MANPAGER` in `env.zsh`), so they use the bat theme.
- Not themed because they use the terminal's 16 ANSI colours (Ghostty's theme already covers them) or have no colour options: git, just, hexyl, shellcheck, mise, worktrunk. gum only if scripts use it (`GUM_*` variables).

- **lazydocker** reads `CONFIG_DIR` (`lazydocker/{latte,mocha}/config.yml`, colours taken from the Catppuccin lazygit theme: no upstream port). `CONFIG_DIR` is generic, so it is set only for the call by the `lazydocker` wrapper in `aliases.zsh` (alias `lzd`), never exported.

## Changing things

- **Accent or flavours**: re-fetch the `*-mauve.yml` files with another accent; edit the palette in `catppuccin.omp.json`; the fzf colours are in `theme.zsh`.
- **After editing bat themes**: `bat cache --build` runs by itself on `chezmoi apply` (script 46).
- **Not themed on purpose**: Zed's JSON keymap, Stage Manager, menu bar layout.
