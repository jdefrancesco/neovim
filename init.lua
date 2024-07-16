-- Packer Bootstrap
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Autocommand to reload Neovim when saving this init.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]])

-- Packer plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- List of plugins
  use 'fmoralesc/vim-pad'
  -- use 'github/copilot.vim'
  use 'scrooloose/nerdtree'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'vim-scripts/c.vim'
  use 'tpope/vim-fugitive'
  use 'morhetz/gruvbox'
  use 'dhananjaylatkar/cscope_maps.nvim'
  use 'nanotech/jellybeans.vim'
  use 'vim-scripts/taglist.vim'
  use 'ap/vim-buftabline'
  use 'majutsushi/tagbar'
  use 'altercation/vim-colors-solarized'
  use 'tpope/vim-commentary'
  use 'godlygeek/tabular'
  use 'flazz/vim-colorschemes'
  use 'mhinz/vim-startify'
  use 'stevearc/vim-arduino'
  use 'ggandor/lightspeed.nvim'
  use 'tpope/vim-surround'
  use 'xolox/vim-session'
  use 'xolox/vim-misc'
  use 'mangeshrex/everblush.vim'
  use 'sainnhe/sonokai'
  use 'jacoborus/tender.vim'
  use 'rr-/vim-hexdec'
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'projekt0n/github-nvim-theme'
  use {'fatih/vim-go', run = ':GoUpdateBinaries'}
  use {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  }
  use {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  }

  -- nvim-cmp and dependencies
  use 'hrsh7th/nvim-cmp' -- Completion plugin
  use 'hrsh7th/cmp-buffer' -- Buffer completions
  use 'hrsh7th/cmp-path' -- Path completions
  use 'hrsh7th/cmp-cmdline' -- Cmdline completions
  use 'saadparwaiz1/cmp_luasnip' -- Snippet completions
  use 'L3MON4D3/LuaSnip' -- Snippet engine
  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Use <Tab> and <S-Tab> to navigate through popup menu
vim.api.nvim_set_keymap('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true, noremap = true})
vim.api.nvim_set_keymap('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true, noremap = true})

-- CoC Configuration
vim.cmd([[
  " Trigger completion with <Tab>
  imap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  imap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

  " Use <c-space> to trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()

  " Use `[g` and `]g` to navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window
  nnoremap <silent> K :lua show_documentation()
]])

-- nvim-cmp setup
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'copilot' }, -- Add Copilot as a source
  }, {
    { name = 'buffer' },
  })
})

-- Copilot settings
vim.g.copilot_no_tab_map = false
-- vim.api.nvim_set_keymap("i", "<C-Space>", 'copilot#Accept("<CR>")', { silent = true, expr = true, script = true })

-- General settings
vim.o.termguicolors = true
vim.cmd('colorscheme gruvbox')
vim.g.airline_theme = 'minimalist'
vim.g.go_bin_path = vim.env.HOME .. "/.local/bin"
vim.g.go_doc_popup_window = 1
vim.g.go_auto_import = 1
vim.g.go_imports_autosave = 1
vim.g.python3_host_prog = '/usr/bin/python3'

-- Switch buffer tabs
vim.api.nvim_set_keymap('n', '<C-M>', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-N>', ':bprev<CR>', { noremap = true, silent = true })

-- Menus
vim.o.display = 'lastline'
vim.o.wildmenu = true
vim.o.wildmode = 'list:full'
vim.o.wildignorecase = true
vim.o.nu = true
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
vim.o.shell = '/bin/zsh'

-- Autocommands
vim.cmd([[
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritePre *.html :normal gg=G
]])

vim.o.encoding = 'utf-8'
vim.o.errorbells = false
vim.o.visualbell = false
vim.o.cursorcolumn = false
vim.o.autoindent = true
vim.o.autochdir = true
vim.o.swapfile = false
vim.o.mouse = 'a'
vim.o.fileformat = 'unix'

-- Leader key
vim.g.mapleader = ','

-- Toggle NERDTree and TagBar
vim.api.nvim_set_keymap('n', '<F2>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F3>', ':TagbarToggle<CR>', { noremap = true, silent = true })

-- Bubble single and multiple lines
vim.api.nvim_set_keymap('n', '<C-Up>', 'ddkP', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Down>', 'ddp', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-Up>', 'xkP`[V`]', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-Down>', 'xp`[V`]', { noremap = true, silent = true })

-- Formatting
vim.api.nvim_set_keymap('n', '<leader>q', 'gqip', { noremap = true, silent = true })

-- Visualize tabs and newlines
vim.o.listchars = 'trail:·,tab:▸\\ ,eol:¬'
vim.api.nvim_set_keymap('n', '<leader>l', ':set list!<CR>', { noremap = true, silent = true }) -- Toggle tabs and EOL
vim.api.nvim_set_keymap('n', '<leader>ec', ':e $MYVIMRC<CR>', { noremap = true, silent = true })

vim.o.belloff = 'all'

-- Build quickfix list
vim.cmd([[
  function! BuildQuickfixList(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
  endfunction
]])

-- Session settings
vim.g.session_autoload = 'no'
vim.g.session_autosave = 'yes'

-- Telescope mappings
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = function(prompt_bufnr)
          local action_state = require('telescope.actions.state')
          local current_picker = action_state.get_current_picker(prompt_bufnr)
          local current_entry = action_state.get_selected_entry()
          local current_path = current_entry.path or current_entry.filename
          local parent_path = vim.fn.fnamemodify(current_path, ":h:h")
          require('telescope.builtin').find_files({cwd = parent_path})
        end,
      },
    },
  },
}

-- Telescope key mappings
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })

-- Enable filetype plugins and indent
vim.cmd('filetype plugin indent on')
vim.cmd('filetype on')

-- Initialize Lightspeed
require'lightspeed'.setup {}

-- Remap 's' key to Lightspeed functionality
vim.api.nvim_set_keymap('n', 's', '<Plug>Lightspeed_s', {})
vim.api.nvim_set_keymap('n', 'S', '<Plug>Lightspeed_S', {})
vim.api.nvim_set_keymap('x', 's', '<Plug>Lightspeed_s', {})
vim.api.nvim_set_keymap('x', 'S', '<Plug>Lightspeed_S', {})
vim.api.nvim_set_keymap('o', 's', '<Plug>Lightspeed_s', {})
vim.api.nvim_set_keymap('o', 'S', '<Plug>Lightspeed_S', {})

