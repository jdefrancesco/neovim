-- Updated: 2026-11 —  + Leap + LSP Modernized

--------------------------------------------------------
-- Lazy.nvim Bootstrap
--------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------
-- Plugin Specification
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
  { "L3MON4D3/LuaSnip" },

  -- Copilot (Lua-native + cmp integration)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = { enabled = true, auto_refresh = true },
        suggestion = { enabled = false, auto_trigger = true, debounce = 75 },
        filetypes = { ["*"] = true },
        copilot_node_command = "node",
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua", "nvim-cmp" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

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

  --------------------------------------------------------------------
  -- Aerial.nvim (Modern Tagbar — LSP/TS Symbols Sidebar)
  --------------------------------------------------------------------
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
        filter_kind = false, -- show all symbols
      })

      -- Keybinding: Toggle symbol sidebar
      vim.keymap.set(
        "n",
        "<F3>",
        "<cmd>AerialToggle!<CR>",
        { noremap = true, silent = true, desc = "Toggle Symbols Sidebar (Aerial)" }
      )
    end,
  },
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

--------------------------------------------------------
-- General Settings
--------------------------------------------------------
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

--------------------------------------------------------
-- Treesitter
--------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "bash", "python", "go" },
  highlight = { enable = true },
  indent = { enable = true },
})

--------------------------------------------------------
-- LSP Setup (future-proofed)
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
-- nvim-cmp Setup (with Copilot)
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
    { name = "copilot" },
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

-- Keymaps
vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.format() end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-M>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-N>", ":bprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>l", ":set list!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ec", ":e $MYVIMRC<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", { noremap = true, silent = true, desc = "Copilot Panel" })
vim.keymap.set({"n", "i", "v"}, "<F1>", "<nop>", { silent = true })
-- Autocommands
vim.cmd([[
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre *.html :normal gg=G
]])
