-- Updated: 2025-10

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Specification
require("lazy").setup({
  -- Core Dependencies
  { "nvim-lua/plenary.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdateSync" },
  { "nvim-lualine/lualine.nvim" },
  { "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-file-browser.nvim" },

  -- Colorschemes (pick your favorite below)
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
  { "L3MON4D3/LuaSnip" },

  -- Utilities
  { "tpope/vim-fugitive" },
  { "tpope/vim-commentary" },
  { "kylechui/nvim-surround", event = "VeryLazy" },
  { "numToStr/Comment.nvim", config = true },
  { "ggandor/leap.nvim", config = true },
  { "dhananjaylatkar/cscope_maps.nvim" },
  { "stevearc/vim-arduino" },
  { "github/copilot.vim" },

  -- ChatGPT integration
  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup({
        openai_api_key = os.getenv("OPENAI_API_TOKEN"),
        providers = {
          openai = {
            disable = false,
            endpoint = "https://api.openai.com/v1/chat/completions",
            secret = os.getenv("OPENAI_API_KEY"),
          },
        },
      })
    end,
  },
})

-- General Settings
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
vim.o.fileformat = "unix"
vim.o.listchars = "trail:·,tab:▸\\ ,eol:¬"

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "bash", "python", "go" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- LSP Setup
vim.lsp.enable('clangd')
vim.lsp.enable('gopls')
vim.lsp.enable('pyright')

-- Completion
local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<Tab>"] = function(fallback)
      local copilot_keys = vim.fn["copilot#Accept"]()
      if copilot_keys ~= "" then
        vim.api.nvim_feedkeys(copilot_keys, "i", true)
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})

-- Telescope Setup
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

-- Bufferline + Lualine
require("bufferline").setup({})
require("lualine").setup({
  options = {
    theme = "auto",
    section_separators = "",
    component_separators = "",
  },
})

-- NvimTree
require("nvim-tree").setup({})
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Keymaps
vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.format() end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-M>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-N>", ":bprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>l", ":set list!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ec", ":e $MYVIMRC<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { noremap = true, silent = true })

-- Autocommands
vim.cmd([[
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre *.html :normal gg=G
]])

-- Silence deprecated lspconfig messages
vim.defer_fn(function()
  local orig = vim.notify
  vim.notify = function(msg, level, opts)
    if msg:match("require%(\'lspconfig\'%)") then return end
    orig(msg, level, opts)
  end
end, 200)

