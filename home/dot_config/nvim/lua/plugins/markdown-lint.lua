-- Markdown lint: give markdownlint-cli2 the global base config, so lines up to 120 columns are fine everywhere.
-- Without it, the tool only reads config files from Neovim's working directory down, and MD013 warns past 80.
-- Same arguments as nvim-lint's default ({ "-" }, stdin) plus --config.
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", vim.fn.expand("~/.markdownlint-cli2.jsonc"), "-" },
      },
    },
  },
}
