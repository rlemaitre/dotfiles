-- Your plugins and overrides of LazyVim plugins go in this directory (one file per topic).
-- Language extras are enabled in lazyvim.json (or with :LazyExtras).
--
-- Language servers, formatters and linters are installed by Mason (LazyVim default),
-- not by mise: this is the one documented exception to the mise-first rule.
-- Tools that mise already provides are removed from Mason's list so each exists once.
local provided_by_mise = { "shfmt" }

-- Servers installed by mise (packages.yaml) because Claude Code's LSP plugins need them on PATH
-- as well. Neovim uses those binaries instead of installing a second copy with Mason.
-- (rust-analyzer: rustaceanvim already looks it up on PATH.)
local servers_from_mise = { "pyright", "gopls", "lua_ls" }

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not vim.tbl_contains(provided_by_mise, tool)
      end, opts.ensure_installed or {})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      for _, name in ipairs(servers_from_mise) do
        opts.servers[name] = vim.tbl_deep_extend("force", opts.servers[name] or {}, { mason = false })
      end
    end,
  },
}
