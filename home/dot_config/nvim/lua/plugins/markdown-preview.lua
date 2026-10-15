-- Markdown preview: the maintained fork instead of LazyVim's iamcco/markdown-preview.nvim.
-- The original has had no commit since 2024-07: it bundles Mermaid 10.2.3, and other websites can read the
-- previewed buffer through its local WebSocket. The fork keeps the same g:mkdp_* options and commands, and bundles
-- Mermaid 12 (https://github.com/iamcco/markdown-preview.nvim/issues/752).
-- Pinned to a release: its build.lua downloads the server binary of that release, which receives every previewed
-- buffer, so read the diff before moving the tag.
return {
  { "iamcco/markdown-preview.nvim", enabled = false },
  {
    "sammaji/markdown-preview.nvim",
    -- both repos are named markdown-preview.nvim: a distinct name keeps lazy.nvim from merging the two specs
    name = "markdown-preview-sammaji.nvim",
    tag = "v0.2.0",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown Preview" },
    },
  },
}
