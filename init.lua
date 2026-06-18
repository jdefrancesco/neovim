-- init.lua — CodeCompanion + Codex
-- Updated: 2026-4-7

--------------------------------------------------------
-- Optional Providers
--------------------------------------------------------
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

--------------------------------------------------------
-- Lazy.nvim Bootstrap
--------------------------------------------------------
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------
-- Leap repo-warning suppression
--------------------------------------------------------
vim.g.leap_suppress_repo_warning = true
do
  local orig_notify = vim.notify
  vim.notify = function(msg, level, opts)
    msg = tostring(msg)
    if msg:match("leap%.nvim") and (msg:match("Codeberg") or msg:match("codeberg") or msg:match("moved")) then
      return
    end
    return orig_notify(msg, level, opts)
  end

  local orig_echo = vim.api.nvim_echo
  vim.api.nvim_echo = function(chunks, history, opts)
    local joined = ""
    if type(chunks) == "table" then
      for _, c in ipairs(chunks) do
        joined = joined .. tostring(c[1])
      end
    else
      joined = tostring(chunks)
    end
    if joined:match("leap%.nvim") and (joined:match("Codeberg") or joined:match("codeberg") or joined:match("moved")) then
      return
    end
    return orig_echo(chunks, history, opts)
  end
end

--------------------------------------------------------
-- Plugins
--------------------------------------------------------
require("lazy").setup({
  -- Core
  { "nvim-lua/plenary.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdateSync" },
  { "nvim-lualine/lualine.nvim" },
  { "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-telescope/telescope.nvim" },
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
  { "kylechui/nvim-surround", event = "VeryLazy" },
  { "numToStr/Comment.nvim", config = true },

  {
    "ggandor/leap.nvim",
    config = function()
      local leap = require("leap")
      leap.setup({})
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")
    end,
  },

  { "dhananjaylatkar/cscope_maps.nvim" },
  { "stevearc/vim-arduino" },

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
      vim.keymap.set("n", "<F3>", "<cmd>AerialToggle!<CR>", { noremap = true, silent = true, desc = "Toggle Symbols Sidebar (Aerial)" })
    end,
  },

  { "coder/claudecode.nvim", dependencies = { "folke/snacks.nvim" }, config = true, },

}, {
  rocks = {
    enabled = false,
  },
})

vim.g.mapleader = ","
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
-- vim.o.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.o.listchars = "trail:·,tab:▸\\ ,eol:¬"

--------------------------------------------------------
-- Treesitter
--------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "bash", "python", "go" },
  highlight = { enable = true },
  indent = { enable = true },
})

--------------------------------------------------------
-- LSP Setup
--------------------------------------------------------
if vim.lsp and vim.lsp.config then
  vim.lsp.config("clangd", {})
  vim.lsp.config("gopls", {})
  vim.lsp.config("pyright", {})
else
  local lspconfig = require("lspconfig")
  lspconfig.clangd.setup({})
  lspconfig.gopls.setup({})
  lspconfig.pyright.setup({})
end

--------------------------------------------------------
-- nvim-cmp Setup (no Copilot source)
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

vim.keymap.set("n", "<C-p>", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.expand("%:p:h"),
    cwd = vim.fn.expand("%:p:h"),
    prompt_title = "File Browser",
  })
end, { noremap = true, silent = true })

--------------------------------------------------------
-- UI (Bufferline + Lualine + NvimTree)
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
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

--------------------------------------------------------
-- Keymaps
--------------------------------------------------------
vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.format() end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-M>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-N>", ":bprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>l", ":set list!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ec", ":e $MYVIMRC<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, "<F1>", "<nop>", { silent = true })

vim.cmd([[
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre *.html :normal gg=G
]])




--------------------------------------------------------
-- Claude Code: Telescope-first command palette
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
            display = entry.name .. " — " .. entry.desc,
            ordinal = entry.name .. " " .. entry.desc .. " " .. entry.cmd,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if not selection or not selection.value then
            return
          end

          vim.cmd(selection.value.cmd)
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

-- Primary interface: command palette
vim.keymap.set("n", "<C-t>", claude_picker, {
  desc = "Claude command palette",
})

-- Terminal fallback, because many terminals do not pass Cmd+p to Neovim
vim.keymap.set("n", "<leader>ap", claude_picker, {
  desc = "Claude command palette",
})

-- Keep this direct mapping because visual selections are modal/contextual
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", {
  desc = "Claude send selection",
})
