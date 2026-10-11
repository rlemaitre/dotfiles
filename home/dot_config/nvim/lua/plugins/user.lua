-- Your plugins and overrides of LazyVim plugins go in this directory (one file per topic).
-- Language extras are enabled in lazyvim.json (or with :LazyExtras).
--
-- Language servers, formatters and linters are installed by Mason (LazyVim default),
-- not by mise: this is the one documented exception to the mise-first rule.
-- Tools that mise already provides are removed from Mason's list so each exists once.
local provided_by_mise = { "shfmt" }

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not vim.tbl_contains(provided_by_mise, tool)
      end, opts.ensure_installed or {})
    end,
  },
}
