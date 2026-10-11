-- Catppuccin, following the terminal/system appearance: latte when light, mocha when dark.
-- Neovim sets 'background' from the terminal (Ghostty switches with macOS), and catppuccin
-- picks the flavour from it.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "auto",
      background = { light = "latte", dark = "mocha" },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
