--------------------------------------------------
--                 Globals                      --
--------------------------------------------------

vim.g.floaterm_shell = "zsh"
vim.g.floaterm_wintype = "split"
vim.g.mapleader = " "

--------------------------------------------------
--                 Options                      --
--------------------------------------------------

vim.o.autoindent = true
vim.o.background = "dark"
vim.o.backspace = "indent,eol,start"
vim.o.clipboard = "unnamedplus"
vim.o.conceallevel = 2
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 2
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.wrap = false

--------------------------------------------------
--                 Keymappings                  --
--------------------------------------------------

do vim.keymap.set("", "<C-Down>", "<C-w>j", { ["desc"] = "Go to down split" }) end
do vim.keymap.set("", "<C-Left>", "<C-w>h", { ["desc"] = "Go to left split" }) end
do vim.keymap.set("", "<C-Right>", "<C-w>l", { ["desc"] = "Go to right split" }) end
do vim.keymap.set("", "<C-Up>", "<C-w>k", { ["desc"] = "Go to up split" }) end
do vim.keymap.set("", "<leader>//", "<cmd>:call nerdcommenter#Comment('', 'Toggle')<CR>", { ["desc"] = "Toggle comment" }) end
do vim.keymap.set("", "<leader>/b", "<cmd>:call nerdcommenter#Comment('', 'AlignBoth')<CR>", { ["desc"] = "Left-and-right-aligned comment" }) end
do vim.keymap.set("", "<leader>/c", "<cmd>:call nerdcommenter#Comment('', 'Comment')<CR>", { ["desc"] = "Comment" }) end
do vim.keymap.set("", "<leader>/i", "<cmd>:call nerdcommenter#Comment('', 'Invert')<CR>", { ["desc"] = "Invert comment" }) end
do vim.keymap.set("", "<leader>/l", "<cmd>:call nerdcommenter#Comment('', 'AlignLeft')<CR>", { ["desc"] = "Left-aligned comment" }) end
do vim.keymap.set("", "<leader>/m", "<cmd>:call nerdcommenter#Comment('', 'Minimal')<CR>", { ["desc"] = "Minimal comment" }) end
do vim.keymap.set("", "<leader>/n", "<cmd>:call nerdcommenter#Comment('', 'Nested')<CR>", { ["desc"] = "Nested comment" }) end
do vim.keymap.set("", "<leader>/u", "<cmd>:call nerdcommenter#Comment('', 'Uncomment')<CR>", { ["desc"] = "Uncomment" }) end
do vim.keymap.set("", "<leader>/y", "<cmd>:call nerdcommenter#Comment('', 'Yank')<CR>", { ["desc"] = "Yank then comment" }) end
do vim.keymap.set("", "<leader>s/", "<cmd>:call nerdcommenter#Comment('', 'Toggle')<CR>", { ["desc"] = "Toggle comment" }) end
do vim.keymap.set("", "<leader>si", function() require('nvim-toggler').toggle() end, { ["desc"] = "Toggle word" }) end
do vim.keymap.set("n", "<leader>+", "<C-a>", { ["desc"] = "Increment number" }) end
do vim.keymap.set("n", "<leader>-", "<C-x>", { ["desc"] = "Decrement number" }) end
do vim.keymap.set("n", "<leader>/$", "<cmd>:call nerdcommenter#Comment('', 'ToEOL')<CR>", { ["desc"] = "Comment until end of line" }) end
do vim.keymap.set("n", "<leader>GG", "<cmd>:Neogit<CR>", { ["desc"] = "Open Neogit" }) end
do vim.keymap.set("n", "<leader>Gc", "<cmd>:Neogit commit<CR>", { ["desc"] = "Commit changes" }) end
do vim.keymap.set("n", "<leader>Tf", "<cmd>tabnew %<CR>", { ["desc"] = "Open current buffer in a new tab" }) end
do vim.keymap.set("n", "<leader>Tn", "<cmd>tabn<CR>", { ["desc"] = "Go to next tab" }) end
do vim.keymap.set("n", "<leader>To", "<cmd>tabnew<CR>", { ["desc"] = "Open new tab" }) end
do vim.keymap.set("n", "<leader>Tp", "<cmd>tabp<CR>", { ["desc"] = "Go to previous tab" }) end
do vim.keymap.set("n", "<leader>Tx", "<cmd>tabclose<CR>", { ["desc"] = "Close current tab" }) end
do vim.keymap.set("n", "<leader>ca", "<cmd>:Lspsaga code_action<CR>", { ["desc"] = "Show code actions" }) end
do vim.keymap.set("n", "<leader>cdn", "<cmd:Lspsaga diagnostic_jump_next<CR>", { ["desc"] = "Jump to next diagnostic" }) end
do vim.keymap.set("n", "<leader>cdp", "<cmd:Lspsaga diagnostic_jump_prev<CR>", { ["desc"] = "Jump to previous diagnostic" }) end
do vim.keymap.set("n", "<leader>cf", "<cmd>:Lspsaga finder<CR>", { ["desc"] = "Show LP finder" }) end
do vim.keymap.set("n", "<leader>cgd", "<cmd:Lspsaga goto_definition<CR>", { ["desc"] = "Go to definition" }) end
do vim.keymap.set("n", "<leader>cgt", "<cmd:Lspsaga goto_type_definition<CR>", { ["desc"] = "Go to type definition" }) end
do vim.keymap.set("n", "<leader>chi", "<cmd:Lspsaga incoming_calls<CR>", { ["desc"] = "Show incoming calls" }) end
do vim.keymap.set("n", "<leader>cho", "<cmd:Lspsaga outgoing_calls<CR>", { ["desc"] = "Show outgoing calls" }) end
do vim.keymap.set("n", "<leader>cj", "<cmd>:Lspsaga hover_doc<CR>", { ["desc"] = "Show hover documentation" }) end
do vim.keymap.set("n", "<leader>co", "<cmd>:Lspsaga outline<CR>", { ["desc"] = "Show code outline" }) end
do vim.keymap.set("n", "<leader>cpd", "<cmd:Lspsaga peek_definition<CR>", { ["desc"] = "Peek definition" }) end
do vim.keymap.set("n", "<leader>cpt", "<cmd:Lspsaga peek_type_definition<CR>", { ["desc"] = "Peek type definition" }) end
do vim.keymap.set("n", "<leader>cr", "<cmd>:Lspsaga rename<CR>", { ["desc"] = "Rename symbol" }) end
do vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { ["desc"] = "Collapse file explorer" }) end
do vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { ["desc"] = "Toggle file explorer" }) end
do vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { ["desc"] = "Toggle file explorer on current file" }) end
do vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { ["desc"] = "Refresh file explorer" }) end
do vim.keymap.set("n", "<leader>tj", "<cmd>FloatermPrev<CR>", { ["desc"] = "Open previous terminal" }) end
do vim.keymap.set("n", "<leader>tk", "<cmd>FloatermNext<CR>", { ["desc"] = "Open next terminal" }) end
do vim.keymap.set("n", "<leader>tn", "<cmd>FloatermNew<CR>", { ["desc"] = "Open new terminal" }) end
do vim.keymap.set("n", "<leader>tt", "<cmd>FloatermToggle<CR>", { ["desc"] = "Toggle terminal" }) end
do vim.keymap.set("n", "<leader>we", "<C-w>=", { ["desc"] = "Make splits equal size" }) end
do vim.keymap.set("n", "<leader>wh", "<C-w>s", { ["desc"] = "Split window horizontally" }) end
do vim.keymap.set("n", "<leader>wv", "<C-w>v", { ["desc"] = "Split window vertically" }) end
do vim.keymap.set("n", "<leader>wx", "<cmd>close<CR>", { ["desc"] = "Close current split" }) end
do vim.keymap.set("n", "x", '"_x', { ["noremap"] = true }) end
do vim.keymap.set("i", "<A-`>A", "Á", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>E", "É", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>I", "Í", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>O", "Ó", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>U", "Ú", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>a", "á", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>e", "é", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>i", "í", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>o", "ó", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-`>u", "ú", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>A", "Á", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>E", "É", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>I", "Í", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>O", "Ó", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>U", "Ú", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>a", "á", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>e", "é", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>i", "í", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>o", "ó", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-e>u", "ú", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>A", "Â", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>E", "Ê", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>I", "Î", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>O", "Ô", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>U", "Û", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>a", "â", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>e", "ê", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>i", "î", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>o", "ô", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-i>u", "û", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>A", "Ä", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>E", "Ë", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>I", "Ï", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>O", "Ö", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>U", "Ü", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>a", "ä", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>e", "ë", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>i", "ï", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>o", "ö", { ["silent"] = true }) end
do vim.keymap.set("i", "<A-u>u", "ü", { ["silent"] = true }) end

--------------------------------------------------
--                 Augroups                     --
--------------------------------------------------

do
  local group = vim.api.nvim_create_augroup("NvimTreeClose", { ["clear"] = true })
  do
  local events = {"BufEnter"}
  local opts = {
  ["callback"] = function(opts)
  local layout = vim.api.nvim_call_function("winlayout", {})
if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then
  vim.cmd("confirm quit")
end

end
,
  ["group"] = group,
  ["nested"] = false,
  ["once"] = false,
  ["pattern"] = "NvimTree_*"
}
  vim.api.nvim_create_autocmd(events, opts)
end

end

do
  local group = vim.api.nvim_create_augroup("highlightOnYank", { ["clear"] = true })
  do
  local events = {"TextYankPost"}
  local opts = {
  ["callback"] = function(opts)
  vim.highlight.on_yank {
  higroup = (
    vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
  ),
  timeout = 200,
}

end
,
  ["group"] = group,
  ["nested"] = false,
  ["once"] = false,
  ["pattern"] = "*"
}
  vim.api.nvim_create_autocmd(events, opts)
end

end


--------------------------------------------------
--               Extra Config (Lua)             --
--------------------------------------------------


-- config for plugin: which-key
do
  function setup()
    
    
    
    local wk = require('which-key')
    wk.setup {
      ["disable"] = {
        ["buftypes"] = {},
        ["filetypes"] = {
          "TelescopePrompt"
        }
      },
      ["plugins"] = {
        ["marks"] = true,
        ["presets"] = {
          ["g"] = true,
          ["motions"] = true,
          ["nav"] = true,
          ["operators"] = true,
          ["text_objects"] = true,
          ["windows"] = true,
          ["z"] = true
        },
        ["registers"] = true,
        ["spelling"] = {
          ["enabled"] = false,
          ["suggestions"] = 20
        }
      },
      ["popup_mappings"] = {
        ["scroll_down"] = "<c-d>",
        ["scroll_up"] = "<c-u>"
      },
      ["window"] = {
        ["border"] = "none",
        ["position"] = "bottom"
      }
    }
    
    -- group names
    wk.register({
      ["<leader>/"] = { name = "Comment line" },
      ["<leader>G"] = { name = "Git" },
      ["<leader>T"] = { name = "Tab Management" },
      ["<leader>c"] = { name = "Code actions" },
      ["<leader>cd"] = { name = "Diagnostics" },
      ["<leader>cg"] = { name = "Go to definition" },
      ["<leader>ch"] = { name = "Call Hierarchy" },
      ["<leader>cp"] = { name = "Peek definition" },
      ["<leader>e"] = { name = "File Explorer" },
      ["<leader>s"] = { name = "Switch things" },
      ["<leader>t"] = { name = "Terminal" },
      ["<leader>w"] = { name = "Window Management" }
    }, { mode = "n" })
    
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: which-key")
    print(output)
  end
end

require("trouble").setup{ ["position"] = "bottom" }


-- config for plugin: treesitter-context
do
  function setup()
    
    
    require('treesitter-context').setup {
      ["mode"] = "cursor",
      ["patterns"] = { ["default"] = {
          "class",
          "function",
          "method"
        } },
      ["trim_scope"] = "outer"
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: treesitter-context")
    print(output)
  end
end


-- config for plugin: treesitter
do
  function setup()
    
    
    
    require('nvim-treesitter.configs').setup({
      ["context_commentstring"] = { ["enable"] = false },
      ["highlight"] = { ["enable"] = true },
      ["incremental_selection"] = {
        ["enable"] = false,
        ["keymaps"] = {
          ["init_selection"] = "gnn",
          ["node_decremental"] = "grm",
          ["node_incremental"] = "grn",
          ["scope_incremental"] = "grc"
        }
      },
      ["indent"] = { ["enable"] = true },
      ["refactor"] = {
        ["highlight_current_scope"] = { ["enable"] = false },
        ["highlight_definitions"] = {
          ["clear_on_cursor_move"] = true,
          ["enable"] = false
        },
        ["navigation"] = {
          ["enable"] = false,
          ["keymaps"] = {
            ["goto_definition"] = "gnd",
            ["goto_next_usage"] = "<a-*>",
            ["goto_previous_usage"] = "<a-#>",
            ["list_definitions"] = "gnD",
            ["list_definitions_toc"] = "gO"
          }
        },
        ["smart_rename"] = {
          ["enable"] = false,
          ["keymaps"] = { ["smart_rename"] = "grr" }
        }
      }
    })
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: treesitter")
    print(output)
  end
end


-- config for plugin: todo-comments
do
  function setup()
    
    
    require('todo-comments').setup {
      ["merge_keywords"] = true,
      ["sign_priority"] = 8,
      ["signs"] = true
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: todo-comments")
    print(output)
  end
end


-- config for plugin: telescope
do
  function setup()
    
    
    
    local telescope = require('telescope')
        telescope.setup {
          extensions = {
      ["manix"] = {},
      ["media_files"] = { ["find_cmd"] = "" }
    },
          defaults = {}
        }
    
        telescope.load_extension('manix')
        telescope.load_extension('media_files') 
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: telescope")
    print(output)
  end
end


-- config for plugin: surround
do
  function setup()
    
    
    require('nvim-surround').setup {}
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: surround")
    print(output)
  end
end


-- config for plugin: project-nvim
do
  function setup()
    
    
    
    require('project_nvim').setup {
      ["datapath"] = "vim.fn.stdpath(\"data\")",
      ["detection_methods"] = {
        "lsp",
        "pattern"
      },
      ["exclude_dirs"] = {},
      ["ignore_lsp"] = {},
      ["manual_mode"] = false,
      ["patterns"] = {
        ".git",
        "package.json",
        ".terraform",
        "go.mod",
        "requirements.yml",
        "pyrightconfig.json",
        "pyproject.toml",
        "build.sbt",
        "Cargo.toml",
        "pom.xml",
        "gradle.properties",
        "build.gradle",
        "settings.gradle",
        "build.sc"
      },
      ["scope_chdir"] = "global",
      ["show_hidden"] = false,
      ["silent_chdir"] = false
    }
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: project-nvim")
    print(output)
  end
end


-- config for plugin: nvim-tree
do
  function setup()
    
    
    require('nvim-tree').setup {
      ["diagnostics"] = {
        ["enable"] = true,
        ["icons"] = {}
      },
      ["filters"] = {
        ["custom"] = {
          ".DS_Store",
          "^.git$"
        },
        ["dotfiles"] = false
      },
      ["git"] = {
        ["enable"] = true,
        ["ignore"] = false
      },
      ["hijack_directories"] = {},
      ["open_on_tab"] = true,
      ["renderer"] = {
        ["full_name"] = true,
        ["group_empty"] = true,
        ["icons"] = {
          ["git_placement"] = "signcolumn",
          ["glyphs"] = {
            ["bookmark"] = "󰆤",
            ["default"] = "",
            ["folder"] = {
              ["arrow_closed"] = "",
              ["arrow_open"] = "",
              ["default"] = "",
              ["empty"] = "",
              ["empty_open"] = "",
              ["open"] = "",
              ["symlink"] = "",
              ["symlink_open"] = ""
            },
            ["git"] = {
              ["deleted"] = "",
              ["ignored"] = "◌",
              ["renamed"] = "➜",
              ["staged"] = "✓",
              ["unmerged"] = "",
              ["unstaged"] = "✗",
              ["untracked"] = "★"
            },
            ["modified"] = "●",
            ["symlink"] = ""
          },
          ["show"] = {
            ["file"] = true,
            ["folder"] = true,
            ["folder_arrow"] = true,
            ["git"] = true
          }
        },
        ["indent_markers"] = { ["enable"] = true },
        ["special_files"] = {
          "Cargo.toml",
          "build.sbt",
          "Makefile",
          "README.md",
          "README.adoc",
          "README.org",
          "readme.md",
          "readme.adoc",
          "readme.org",
          "package.json"
        }
      },
      ["sync_root_with_cwd"] = true,
      ["system_open"] = {},
      ["trash"] = {},
      ["update_focused_file"] = { ["enable"] = true },
      ["view"] = {
        ["number"] = true,
        ["relativenumber"] = true
      }
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: nvim-tree")
    print(output)
  end
end


-- config for plugin: nvim-toggler
do
  function setup()
    
    
    
    require('nvim-toggler').setup({
      ["inverses"] = {},
      ["remove_default_keybinds"] = true
    })
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: nvim-toggler")
    print(output)
  end
end

-- config for plugin: nvim-cmp
do
  function setup()
    local cmp = require('cmp') -- this is needed

    cmp.setup({
  ["completion"] = { ["completeopt"] = "menu,menuone,preview,noselect" },
  ["enabled"] = true,
  ["mapping"] = {
  ["<C-Space>"] = cmp.mapping.complete(),
  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  ["<C-e>"] = cmp.mapping.abort(),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-j>"] = cmp.mapping.select_next_item(),
  ["<C-k>"] = cmp.mapping.select_prev_item(),
  ["<CR>"] = cmp.mapping.confirm({ select = false }),
  ["<Down>"] = cmp.mapping.select_next_item(),
  ["<Esc>"] = cmp.mapping.abort(),
  ["<LeftMouse>"] = cmp.mapping.complete(),
  ["<PageDown>"] = cmp.mapping.scroll_docs(4),
  ["<PageUp>"] = cmp.mapping.scroll_docs(-4),
  ["<Up>"] = cmp.mapping.select_prev_item()
},
  ["snippet"] = { ["expand"] = function(args) require("luasnip").lsp_expand(args.body) end },
  ["sources"] = {
    {
    ["entry_filter"] = nil,
    ["name"] = "buffer"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "conventionalcommits"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "copilot"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "emoji"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "git"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "luasnip"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "nvim_lsp"
  },
    {
    ["entry_filter"] = nil,
    ["name"] = "path"
  }
  }
})

    -- extra config of sources
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: nvim-cmp")
    print(output)
  end
end

require('nvim-autopairs').setup({})


-- config for plugin: nerdcommenter
do
  function setup()
    
    vim.g.NERDCompactSexyComs = 1
vim.g.NERDCreateDefaultMappings = 0
vim.g.NERDDefaultAlign = "left"
vim.g.NERDSpaceDelims = 1
    
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: nerdcommenter")
    print(output)
  end
end

require('neogit').setup({
  ["commit_popup"] = { ["kind"] = "floating" },
  ["integrations"] = { ["diffview"] = false },
  ["kind"] = "floating",
  ["mappings"] = {},
  ["sections"] = {},
  ["signs"] = {}
})

require("lualine").setup({ ["options"] = {
    ["globalstatus"] = false,
    ["refresh"] = {
      ["statusline"] = 1000,
      ["tabline"] = 1000,
      ["winbar"] = 1000
    },
    ["theme"] = "nord"
  } })

-- config for plugin: lspsaga
do
  function setup()
    
    
    require('lspsaga').setup {
      ["beacon"] = {
        ["enable"] = true,
        ["frequency"] = 7
      },
      ["callhierarchy"] = {
        ["keys"] = {
          ["edit"] = "e",
          ["expand_collapse"] = "u",
          ["jump"] = "o",
          ["quit"] = "q",
          ["split"] = "i",
          ["tabe"] = "t",
          ["vsplit"] = "v"
        },
        ["show_detail"] = true
      },
      ["code_action"] = {
        ["extend_gitsigns"] = true,
        ["keys"] = {
          ["exec"] = "<CR>",
          ["quit"] = "q"
        },
        ["num_shortcut"] = true
      },
      ["definition"] = {
        ["edit"] = "<C-c>o",
        ["quit"] = "q",
        ["split"] = "<C-c>i",
        ["tabe"] = "<C-c>t",
        ["vsplit"] = "<C-c>v"
      },
      ["diagnostic"] = {
        ["jump_num_shortcut"] = true,
        ["keys"] = {
          ["exec_action"] = "o",
          ["expand_or_jump"] = "<CR>",
          ["quit"] = "q",
          ["quit_in_show"] = {
            "q",
            "<ESC>"
          }
        },
        ["show_code_action"] = true,
        ["show_source"] = true
      },
      ["finder"] = { ["keys"] = {
          ["close_in_preview"] = "<ESC>",
          ["expand_or_jump"] = "o",
          ["jump_to"] = "p",
          ["quit"] = {
            "q",
            "<ESC>"
          },
          ["split"] = "i",
          ["tabe"] = "t",
          ["tabnew"] = "r",
          ["vsplit"] = "v"
        } },
      ["hover"] = {
        ["open_browser"] = "!chrome",
        ["open_link"] = "gx"
      },
      ["lightbulb"] = {
        ["enable"] = true,
        ["enable_in_insert"] = true,
        ["sign"] = true,
        ["virtual_text"] = true
      },
      ["outline"] = {
        ["auto_close"] = true,
        ["auto_preview"] = true,
        ["auto_refresh"] = true,
        ["auto_resize"] = false,
        ["close_after_jump"] = false,
        ["keys"] = {
          ["expand_or_jump"] = "o",
          ["quit"] = "q"
        },
        ["win_position"] = "right"
      },
      ["preview"] = {
        ["lines_above"] = 0,
        ["lines_below"] = 10
      },
      ["rename"] = {
        ["exec"] = "<CR>",
        ["in_select"] = true,
        ["quit"] = "<C-c>"
      },
      ["request_timeout"] = 2000,
      ["scroll_preview"] = {
        ["scroll_down"] = "<C-f>",
        ["scroll_up"] = "<C-b>"
      },
      ["symbol_in_winbar"] = {
        ["color_mode"] = true,
        ["enable"] = true,
        ["separator"] = " › ",
        ["show_file"] = true
      }
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: lspsaga")
    print(output)
  end
end


-- config for plugin: lspkind
do
  function setup()
    
    
    
    require('lspkind').init { ["mode"] = "symbol_text" }
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: lspkind")
    print(output)
  end
end


-- config for plugin: lspconfig
do
  function setup()
    
    
    
    
    
    do -- lsp server config bashls
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["bashls"].setup(setup)
    end -- lsp server config bashls
    
    do -- lsp server config clangd
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["clangd"].setup(setup)
    end -- lsp server config clangd
    
    do -- lsp server config cssls
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["cssls"].setup(setup)
    end -- lsp server config cssls
    
    do -- lsp server config eslint
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["eslint"].setup(setup)
    end -- lsp server config eslint
    
    do -- lsp server config gopls
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["gopls"].setup(setup)
    end -- lsp server config gopls
    
    do -- lsp server config hls
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["hls"].setup(setup)
    end -- lsp server config hls
    
    do -- lsp server config html
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["html"].setup(setup)
    end -- lsp server config html
    
    do -- lsp server config jsonls
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["jsonls"].setup(setup)
    end -- lsp server config jsonls
    
    do -- lsp server config kotlin-language-server
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["kotlin_language_server"].setup(setup)
    end -- lsp server config kotlin-language-server
    
    do -- lsp server config lua-language-server
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["lua_ls"].setup(setup)
    end -- lsp server config lua-language-server
    
    do -- lsp server config nil
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["nil_ls"].setup(setup)
    end -- lsp server config nil
    
    do -- lsp server config ocamllsp
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["ocamllsp"].setup(setup)
    end -- lsp server config ocamllsp
    
    do -- lsp server config pyright
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["pyright"].setup(setup)
    end -- lsp server config pyright
    
    do -- lsp server config rust-analyzer
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["rust_analyzer"].setup(setup)
    end -- lsp server config rust-analyzer
    
    do -- lsp server config taplo
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["taplo"].setup(setup)
    end -- lsp server config taplo
    
    do -- lsp server config terraform-ls
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["terraformls"].setup(setup)
    end -- lsp server config terraform-ls
    
    do -- lsp server config typescript-language-server
      
      
    local setup =  {
      on_attach = function(client, bufnr)
        
        
      end,
      
    }
    
      require('lspconfig')["tsserver"].setup(setup)
    end -- lsp server config typescript-language-server
    
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: lspconfig")
    print(output)
  end
end


-- config for plugin: lsp-lines
do
  function setup()
    
    
    
    require('lsp_lines').setup()
    
    -- Disable virtual_text since it's redundant due to lsp_lines.
    vim.diagnostic.config({
      virtual_text = false,
    })
    
    
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: lsp-lines")
    print(output)
  end
end


-- config for plugin: indent-blankline
do
  function setup()
    
    
    
    
    require('ibl').setup {
      ["indent"] = {
        ["char"] = "┊",
        ["repeat_linebreak"] = true,
        ["smart_indent_cap"] = true
      },
      ["scope"] = {
        ["enabled"] = true,
        ["show_end"] = true,
        ["show_start"] = true
      }
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: indent-blankline")
    print(output)
  end
end


-- config for plugin: gitsigns
do
  function setup()
    
    
    require('gitsigns').setup {
      ["current_line_blame"] = true,
      ["current_line_blame_opts"] = {
        ["delay"] = 1000,
        ["ignore_whitespace"] = false,
        ["virt_text"] = true,
        ["virt_text_pos"] = "eol"
      },
      ["linehl"] = false,
      ["numhl"] = false,
      ["signcolumn"] = true,
      ["word_diff"] = false
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: gitsigns")
    print(output)
  end
end


-- config for plugin: diffview
do
  function setup()
    
    
    require('diffview').setup {
      ["diff_binaries"] = false,
      ["use_icons"] = true,
      ["watch_index"] = true
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: diffview")
    print(output)
  end
end



-- config for plugin: comment-frame
do
  function setup()
    
    
    require('nvim-comment-frame').setup {
      ["add_comment_above"] = true,
      ["auto_indent"] = true,
      ["disable_default_keymap"] = false,
      ["end_str"] = "//",
      ["fill_char"] = "-",
      ["frame_width"] = 70,
      ["keymap"] = "<leader>/f",
      ["line_wrap_len"] = 50,
      ["multiline_keymap"] = "<leader>/m",
      ["start_str"] = "//"
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: comment-frame")
    print(output)
  end
end


-- config for plugin: colorizer
do
  function setup()
    
    
    require('colorizer').setup {
      ["filtypes"] = {
        "*"
      },
      ["user_default_options"] = {
        ["AARRGGBB"] = true,
        ["RGB"] = true,
        ["RRGGBB"] = true,
        ["RRGGBBAA"] = true,
        ["css"] = true,
        ["css_fn"] = true,
        ["hls_fn"] = true,
        ["mode"] = "background",
        ["names"] = true,
        ["rgb_fn"] = true,
        ["sass"] = {
          ["enable"] = true,
          ["parsers"] = {
            "css"
          }
        },
        ["tailwind"] = true,
        ["virtualtext"] = "■"
      }
    }
    
    
    
  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: colorizer")
    print(output)
  end
end

require('bufferline').setup{ ["options"] = {
    ["separator_style"] = "slant",
    ["show_close_icon"] = true,
    ["show_tab_indicators"] = true
  } }


vim.cmd([[colorscheme nord]])


