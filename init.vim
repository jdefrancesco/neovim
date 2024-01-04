set nocompatible


call plug#begin('~/.vim/plugged')
    Plug 'fmoralesc/vim-pad'
    " NERDTree
    Plug 'scrooloose/nerdtree'
    " Fun status bar
    Plug 'vim-airline/vim-airline'
    " Git co-pilot
    Plug 'github/copilot.vim'
    " C Vim extension
    Plug 'vim-scripts/c.vim'
    " Git plugin
    Plug 'tpope/vim-fugitive'
    " Vim themes
    Plug 'morhetz/gruvbox'
    " Jellybean colorscheme
    Plug 'nanotech/jellybeans.vim'
    " Go programming extension
    Plug 'fatih/vim-go'
    " Taglist
    Plug 'vim-scripts/taglist.vim'
    " Buftabline
    Plug 'ap/vim-buftabline'
    " Tagbar
    Plug 'majutsushi/tagbar'
    " Vim solarized colors
    Plug 'altercation/vim-colors-solarized'
    " Auto comment/decomment
    Plug 'tpope/vim-commentary'
    " Tabular
    Plug 'godlygeek/tabular'
    " Sneak - Easy movement
    Plug 'justinmk/vim-sneak'
    " More themes
    Plug 'flazz/vim-colorschemes'
    " Vim Startify Menu
    Plug 'mhinz/vim-startify'
    " Arduino
    Plug 'stevearc/vim-arduino'
    " Surround
    Plug 'tpope/vim-surround'
    " Session plugin
    Plug 'xolox/vim-session'
    " Vim misc
    Plug 'xolox/vim-misc'
    " Everblush theme
    Plug 'mangeshrex/everblush.vim'
    " Awesome color theme
    Plug 'sainnhe/sonokai'
    " Tender colorscheme
    Plug 'jacoborus/tender.vim'
    " Convert number under cursor to hex or back.
    Plug 'rr-/vim-hexdec'
    " LSP
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " New CtrlP
    Plug 'ctrlpvim/ctrlp.vim'
call plug#end()

let g:go_bin_path = $HOME."/go/bin"
let g:go_doc_popup_window = 1

" Colors
set termguicolors
colorscheme sonokai
let g:airline_theme = 'sonokai'

if has('gui_macvim')
    " set guifont=Hack:h10
    set guifont=TerminusTTF:h14
    set linespace=0
endif

" Sneak config options
let g:sneak#label = 1
let g:ctrlp_show_hidden=1

" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
noremap <silent><expr> <c-space> coc#refresh()`
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

nnoremap <C-M> :bnext<CR>
nnoremap <C-N> :bprev<CR>

" Menus
set display+=lastline
set wildmenu
set wildmode=list:full
set wildignorecase
set nu

set ttyfast
set nowrap

set tabstop=4
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
set autoindent
set smartindent
set nocursorline
set ignorecase
set smartcase
set incsearch
" set hlsearch

set shell=/bin/zsh

" Get rid of trailing white space when we save.
autocmd BufWritePre * %s/\s\+$//e
" Re-indent html when we write the file.
autocmd BufWritePre *.html :normal gg=G

set encoding=utf-8
set noerrorbells
set novisualbell
set nocursorcolumn
set autochdir
set noswapfile
set nocursorcolumn
set mouse=a
set fileformat=unix

filetype plugin indent on
filetype on

" leader key set to comma
let mapleader=","

" Toggle NERDTree
nnoremap <F3> :NERDTreeToggle<CR>
" Toggle TagBar
nnoremap <F2> :TagbarToggle<CR>

"" Bubble single lines
nmap <C-Up> ddkP
nmap <C-Down> ddp


" Bubble multiple lines
vmap <C-Up> xkP`[V`]
vmap <C-Down> xp`[V`]

" Formatting
map <leader>q gqip

" Visualize tabs and newlines
set listchars=trail:·,tab:▸\ ,eol:¬
nnoremap <leader>l :set list!<CR> " Toggle tabs and EOL
nnoremap <leader>ec :e $MYVIMRC<CR>

set belloff=all


" Copilot use CtrlJ to complete
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

"
" Vimscripts file settings =========== {{{{
" augroup filetype_vim
"     autocmd!
"     autocmd FileType vim setlocal foldmethod=marker
" augroup END
" }}}}
"
let g:session_autoload = 'no'
let g:session_autosave = 'yes'
