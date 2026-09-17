-- init.lua — Cleaned Neovim config
-- Updated: 2026-06-25
--
-- Notes:
-- - Leader is set before lazy.nvim loads plugins.
-- - Removed global vim.notify/vim_echo monkeypatch for Leap warnings.
-- - Treesitter setup now lives inside the lazy.nvim plugin spec, so Neovim
--   will not crash if nvim-treesitter is missing or not loaded yet.
-- - Treesitter markdown highlighting is temporarily disabled to avoid the
--   decoration-provider crash you saw in .md files.
-- - <C-p> opens Telescope file browser.
-- - Claude command palette is available at <leader>ap.
-- - Leap has explicit labels and timeout settings.

--------------------------------------------------------
-- Optional Providers
--------------------------------------------------------
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

--------------------------------------------------------
-- Leader keys
--------------------------------------------------------
vim.g.mapleader = ","
vim.g.maplocalleader = ","

--------------------------------------------------------
-- Lazy.nvim Bootstrap
--------------------------------------------------------
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------
-- Plugins
--------------------------------------------------------
require("lazy").setup({
  -- Core
  { "nvim-lua/plenary.nvim" },

{
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    require("nvim-treesitter").install({
      "c",
      "cpp",
      "lua",
      "bash",
      "python",
      "go",
      "markdown",
      "markdown_inline",
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "c",
        "cpp",
        "lua",
        "sh",
        "python",
        "go",
      },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
},


  { "nvim-lualine/lualine.nvim" },
  { "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-telescope/telescope.nvim", dependencies = "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope-file-browser.nvim" },

  -- Colorschemes
  { "rebelot/kanagawa.nvim" },
  { "sainnhe/sonokai" },
  { "projekt0n/github-nvim-theme" },

  -- LSP + Completion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "saadparwaiz1/cmp_luasnip" },
  { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },

  -- Utilities
  { "tpope/vim-fugitive" },
  { "tpope/vim-commentary" },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "numToStr/Comment.nvim", config = true },
  { "dhananjaylatkar/cscope_maps.nvim" },
  { "stevearc/vim-arduino" },

  -- Leap
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    name = "leap.nvim",
    config = function()
      local leap = require("leap")

      leap.setup({
        labels = {
          "s", "f", "n", "j", "k", "l", "h", "o",
          "d", "w", "e", "m", "b", "u", "y", "v",
          "r", "g", "t", "c", "x", "z",
        },
      })

      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", {
        desc = "Leap forward",
      })

      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", {
        desc = "Leap backward",
      })

      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", {
        desc = "Leap from window",
      })
    end,
  },

  -- Aerial.nvim
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown", "man" },
        layout = {
          max_width = { 40, 0.25 },
          min_width = 20,
          default_direction = "right",
          placement = "edge",
        },
        show_guides = true,
        filter_kind = false,
      })

      local function aerial_toggle()
        vim.cmd("AerialToggle!")
      end

      for _, lhs in ipairs({ "<F3>", "<Esc>OR", "<Esc>[13~" }) do
        vim.keymap.set("n", lhs, aerial_toggle, {
          noremap = true,
          silent = true,
          desc = "Toggle Symbols Sidebar (Aerial)",
        })
      end
    end,
  },

  -- Claude Code
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      git_repo_cwd = true,
      log_level = "info",
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.34,
        auto_close = true,
      },
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = false,
        keep_terminal_focus = false,
        auto_resize_terminal = true,
      },
      track_selection = true,
      focus_after_send = false,
    },
  },
}, {
  rocks = {
    enabled = false,
  },
})

--------------------------------------------------------
-- General Options
--------------------------------------------------------
vim.o.termguicolors = true
vim.cmd("colorscheme sonokai")

vim.o.completeopt = "menuone,noselect"
vim.o.number = true
vim.o.wrap = false
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.mouse = "a"
vim.o.swapfile = false
vim.o.encoding = "utf-8"
vim.o.shell = "/bin/zsh"
vim.o.belloff = "all"
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.o.listchars = "trail:·,tab:▸\\ ,eol:¬"

-- Multi-key mappings and Leap label selection.
vim.o.timeout = true
vim.o.timeoutlen = 500
vim.o.ttimeout = true
-- Function keys are multi-byte terminal escape sequences. 50ms is a
-- little too aggressive over SSH/tmux/iTerm and can make F2/F3 decode
-- as raw escape bytes instead of <F2>/<F3>.
vim.o.ttimeoutlen = 100

--------------------------------------------------------
-- LSP Setup
--------------------------------------------------------
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if ok_cmp_lsp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local lsp_servers = { "clangd", "gopls", "pyright" }

-- Neovim 0.11+: vim.lsp.config() only defines/merges configs;
-- vim.lsp.enable() is the step that actually activates them.
if vim.lsp and vim.lsp.config and vim.lsp.enable then
  vim.lsp.config("*", {
    capabilities = capabilities,
  })

  vim.lsp.config("clangd", {
    root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
  })

  vim.lsp.config("gopls", {
    root_markers = { "go.work", "go.mod", ".git" },
  })

  vim.lsp.config("pyright", {
    root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    },
  })

  vim.lsp.enable(lsp_servers)
else
  -- Neovim <= 0.10 fallback.
  local lspconfig = require("lspconfig")
  local util = require("lspconfig.util")

  lspconfig.clangd.setup({
    capabilities = capabilities,
    root_dir = util.root_pattern(".clangd", "compile_commands.json", "compile_flags.txt", ".git"),
  })

  lspconfig.gopls.setup({
    capabilities = capabilities,
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  })

  lspconfig.pyright.setup({
    capabilities = capabilities,
    root_dir = util.root_pattern(
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git"
    ),
  })
end

vim.keymap.set("n", "<F5>", "<cmd>NvimTreeToggle<CR>", {
  silent = true,
  desc = "Toggle file tree",
})

vim.keymap.set("n", "<F6>", "<cmd>AerialToggle!<CR>", {
  silent = true,
  desc = "Toggle Symbols Sidebar (Aerial)",
})
--------------------------------------------------------
-- nvim-cmp Setup
--------------------------------------------------------
local cmp = require("cmp")

cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },

  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

--------------------------------------------------------
-- Telescope
--------------------------------------------------------
require("telescope").setup({
  extensions = {
    file_browser = {
      grouped = true,
      hidden = true,
      respect_gitignore = false,
    },
  },
})

require("telescope").load_extension("file_browser")

local function telescope_file_browser()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.expand("%:p:h"),
    cwd = vim.fn.expand("%:p:h"),
    prompt_title = "File Browser",
  })
end

vim.keymap.set("n", "<C-p>", telescope_file_browser, {
  noremap = true,
  silent = true,
  desc = "Telescope file browser",
})

vim.keymap.set("n", "<leader>fb", telescope_file_browser, {
  noremap = true,
  silent = true,
  desc = "Telescope file browser",
})

--------------------------------------------------------
-- UI: Bufferline + Lualine + NvimTree
--------------------------------------------------------
require("bufferline").setup({})

require("lualine").setup({
  options = {
    theme = "auto",
    section_separators = "",
    component_separators = "",
  },
})

require("nvim-tree").setup({})

local function nvim_tree_toggle()
  vim.cmd("NvimTreeToggle")
end
--------------------------------------------------------
-- General Keymaps
--------------------------------------------------------
vim.keymap.set("n", "<leader>r", function()
  vim.lsp.buf.format()
end, {
  noremap = true,
  silent = true,
  desc = "Format buffer",
})

vim.keymap.set("n", "<C-M>", "<cmd>bnext<CR>", {
  noremap = true,
  silent = true,
  desc = "Next buffer",
})

vim.keymap.set("n", "<C-N>", "<cmd>bprev<CR>", {
  noremap = true,
  silent = true,
  desc = "Previous buffer",
})

vim.keymap.set("n", "<leader>l", "<cmd>set list!<CR>", {
  noremap = true,
  silent = true,
  desc = "Toggle invisible characters",
})

vim.keymap.set("n", "<leader>ec", "<cmd>e $MYVIMRC<CR>", {
  noremap = true,
  silent = true,
  desc = "Edit init.lua",
})

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {
  noremap = true,
  silent = true,
  desc = "Open diagnostic float",
})

vim.keymap.set({ "n", "i", "v" }, "<F1>", "<nop>", {
  silent = true,
  desc = "Disable F1 help",
})

--------------------------------------------------------
-- Autocmds
--------------------------------------------------------
local autocmd_group = vim.api.nvim_create_augroup("UserConfig", {
  clear = true,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmd_group,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmd_group,
  pattern = "*.html",
  command = "normal! gg=G",
})

--------------------------------------------------------
-- Claude Code: Telescope-first Command Palette
--------------------------------------------------------
local function claude_picker()
  local ok, _ = pcall(require, "telescope")
  if not ok then
    vim.notify("telescope.nvim is not installed", vim.log.levels.ERROR)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local commands = {
    { name = "Toggle Claude", cmd = "ClaudeCode", desc = "Open or close Claude pane" },
    { name = "Focus Claude", cmd = "ClaudeCodeFocus", desc = "Move cursor to Claude pane" },
    { name = "Resume conversation", cmd = "ClaudeCode --resume", desc = "Resume old session" },
    { name = "Continue latest", cmd = "ClaudeCode --continue", desc = "Continue latest session" },
    { name = "Select model", cmd = "ClaudeCodeSelectModel", desc = "Choose model" },
    { name = "Add current buffer", cmd = "ClaudeCodeAdd %", desc = "Add current file as context" },
    { name = "Send selection", cmd = "ClaudeCodeSend", desc = "Send visual selection" },
    { name = "Status", cmd = "ClaudeCodeStatus", desc = "Show Claude status" },
    { name = "Accept diff", cmd = "ClaudeCodeDiffAccept", desc = "Accept current diff" },
    { name = "Reject diff", cmd = "ClaudeCodeDiffDeny", desc = "Reject current diff" },
    { name = "Close diffs", cmd = "ClaudeCodeCloseAllDiffs", desc = "Close all diff windows" },
    { name = "Open/create CLAUDE.md", cmd = "ClaudeOpenMemory", desc = "Project instructions" },
  }

  pickers
    .new({}, {
      prompt_title = "Claude Code",
      finder = finders.new_table({
        results = commands,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name .. " - " .. entry.desc,
            ordinal = entry.name .. " " .. entry.desc .. " " .. entry.cmd,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if selection and selection.value and selection.value.cmd then
            vim.cmd(selection.value.cmd)
          end
        end)

        return true
      end,
    })
    :find()
end

vim.api.nvim_create_user_command("ClaudeOpenMemory", function()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

  if vim.v.shell_error ~= 0 or root == nil or root == "" then
    root = vim.fn.getcwd()
  end

  local path = root .. "/CLAUDE.md"

  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({
      "# Project instructions",
      "",
      "- Prefer minimal, reviewable diffs.",
      "- Do not rewrite unrelated code.",
      "- Run tests before claiming a fix works.",
      "- Explain security-sensitive changes.",
      "- Ask before adding new dependencies.",
      "",
    }, path)
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, {})

-- Claude command palette.
vim.keymap.set("n", "<C-l>", claude_picker, {
  desc = "Claude command palette",
})

-- Keep direct visual mapping because selected text is contextual.
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<CR>", {
  desc = "Claude send selection",
})

-- Bubble line up or down
vim.keymap.set("n", "<leader>k", ":m .-2<CR>==")
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
-- Visual bubble line up or down
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
