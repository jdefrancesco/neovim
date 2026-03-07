-- init.lua — CodeCompanion + Codex (OpenAI Responses)
-- Updated: 2026-03-05

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
  { "L3MON4D3/LuaSnip" },

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

  --------------------------------------------------------
  -- CodeCompanion (Codex via OpenAI Responses)
  --------------------------------------------------------
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionCmd", "CodeCompanionActions" },
    keys = {
      { "<leader>ca", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion Actions", mode = { "n", "v" } },
      { "<leader>ch", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CodeCompanion Chat Toggle", mode = { "n", "v" } },
      { "<leader>ci", "<cmd>CodeCompanion inline<CR>", desc = "CodeCompanion Inline", mode = { "n", "v" } },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local adapters = require("codecompanion.adapters")

      require("codecompanion").setup({
        -- Use interactions mapping to assign adapters for each mode
        interactions = {
          chat   = { adapter = "openai_responses_codex" },
          cmd    = { adapter = "openai_responses_codex" },
          inline = { adapter = "openai_responses_codex_inline" },
        },

        -- Define custom adapters using openai_responses to call Codex models
        adapters = {
          http = {
            -- Streaming chat/cmd adapter for Codex
            openai_responses_codex = function()
              return adapters.extend("openai_responses", {
                env = { api_key = "OPENAI_API_KEY" },
                opts = { stream = true },
                schema = {
                  model = {
                    default = "gpt-5.3-codex",
                    -- Provide fallback choices for codex models
                    choices = function(_, _)
                      return {
                        ["gpt-5.3-codex"] = {
                          formatted_name = "GPT-5.3 Codex",
                          opts = { has_function_calling = true, has_vision = true, can_reason = true },
                        },
                        ["gpt-5-codex"] = {
                          formatted_name = "GPT-5 Codex",
                          opts = { has_function_calling = true, has_vision = true, can_reason = true },
                        },
                        ["codex-mini-latest"] = {
                          formatted_name = "Codex-mini",
                          opts = { has_function_calling = true, has_vision = true, can_reason = true },
                        },
                      }
                    end,
                  },
                  ["reasoning.effort"] = { default = "medium" },
                  ["reasoning.summary"] = { default = "auto" },
                  -- Remove unsupported sampling parameters
                  top_p = { default = nil },
                  temperature = { default = nil },
                },
                -- Remove unsupported parameters via request handler
                handlers = {
                  request = {
                    build_parameters = function(_, params, messages)
                      -- Explicitly drop unsupported sampling parameters
                      params.top_p = nil
                      params.temperature = nil
                      return params
                    end,
                  },
                },
              })
            end,

            -- Non-streaming inline adapter for Codex
            openai_responses_codex_inline = function()
              return adapters.extend("openai_responses", {
                env = { api_key = "OPENAI_API_KEY" },
                opts = { stream = false, tools = true, vision = true },
                schema = {
                  model = {
                    default = "gpt-5.3-codex",
                    choices = function(_, _)
                      return {
                        ["gpt-5.3-codex"] = {
                          formatted_name = "GPT-5.3 Codex",
                          opts = { has_function_calling = true, has_vision = true, can_reason = true, stream = false },
                        },
                        ["gpt-5-codex"] = {
                          formatted_name = "GPT-5 Codex",
                          opts = { has_function_calling = true, has_vision = true, can_reason = true, stream = false },
                        },
                        ["codex-mini-latest"] = {
                          formatted_name = "Codex-mini",
                          opts = { has_function_calling = true, has_vision = true, can_reason = true, stream = false },
                        },
                      }
                    end,
                  },
                  ["reasoning.effort"] = { default = "medium" },
                  ["reasoning.summary"] = { default = "auto" },
                  -- Remove unsupported sampling parameters for inline
                  top_p = { default = nil },
                  temperature = { default = nil },
                },
                handlers = {
                  request = {
                    build_parameters = function(_, params, messages)
                      params.top_p = nil
                      params.temperature = nil
                      return params
                    end,
                  },
                },
              })
            end,
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

--------------------------------------------------------
-- Autocommands
--------------------------------------------------------
vim.cmd([[
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre *.html :normal gg=G
]])
