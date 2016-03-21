" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" ------------------------------------------------------------------------------
" General Config
" ------------------------------------------------------------------------------
set number                     " Line numbers
set relativenumber             " Relative numbering
set backspace=indent,eol,start " Allow backspace in insert mode
set history=1000               " Store lots of :cmdline history
set showcmd                    " Show incomplete cmds down the bottom
set showmode                   " Show current mode down the bottom
set visualbell                 " No sounds
set autoread                   " Reload files changed outside vim
set hidden                     " Allow buffers to exist in background
set noswapfile                 " No swap file
set nobackup                   " No backup
set nowb                       " No write-backup
set laststatus=2               " Always show statusline
set t_Co=16                    " Set terminal color to 16
set colorcolumn=80             " Highlight column 80
syntax on                      " Turn on syntax
syntax enable                  " Enable syntax

" ------------------------------------------------------------------------------
"  Set ESC and Leader
" ------------------------------------------------------------------------------
:imap jj <Esc>
:let mapleader = ' '

" ------------------------------------------------------------------------------
" Move normally between wrapped lines
" ------------------------------------------------------------------------------
nmap j gj
nmap k gk

" ------------------------------------------------------------------------------
" Indentation and Linebreaks
" ------------------------------------------------------------------------------
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set nowrap
set linebreak

" ------------------------------------------------------------------------------
" Search Config
" ------------------------------------------------------------------------------
set hlsearch
set incsearch
set smartcase

" ------------------------------------------------------------------------------
" Automatically save file
" ------------------------------------------------------------------------------
autocmd FocusLost * silent! wa

" ------------------------------------------------------------------------------
" Activate Airline smarter tab line
" ------------------------------------------------------------------------------
let g:airline#extensions#tabline#enabled = 1

" ------------------------------------------------------------------------------
" Multi-Cursor Config
" ------------------------------------------------------------------------------
let g:multi_cursor_quit_key='jj'

" ------------------------------------------------------------------------------
" Persistent Undo -- " Keep undo history across sessions, by storing in file.
" ------------------------------------------------------------------------------
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ------------------------------------------------------------------------------
" Space Based Keybindings
" ------------------------------------------------------------------------------

" Buffer
nnoremap <leader><Tab> :e#<CR>                   " Switch to last buffer
nnoremap <leader>bb :CtrlPBuffer<CR>             " List
nnoremap <leader>bn :bnext<CR>                   " Next
nnoremap <leader>bp :bprevious<CR>               " Previous
nnoremap <leader>bd :bdelete<CR>                 " Delete

" Linting
nnoremap <leader>en :SyntasticCheck<CR>          " Lint now
nnoremap <leader>ee :Errors<CR>                  " List errors
nnoremap <leader>et :SyntasticToggleMode<CR>     " List errors

" Meta
nnoremap <leader>_d :e $MYVIMRC<CR>              " Edit .vimrc
nnoremap <leader>_r :so $MYVIMRC<CR>             " Reload .vimrc

" Project
nnoremap <silent> <leader>pt :NERDTreeToggle<CR> " Open a horizontal split and switch to it (,h)
nnoremap <silent> <leader>pF :NERDTreeFind<CR>   " Open a horizontal split and switch to it (,h)
nnoremap <leader>pf :CtrlP<CR>

" Window splits
nnoremap <leader>wv <C-w>v<C-w>l                 " Split vertically
nnoremap <leader>wh <C-w>s<C-w>j                 " Split horizontally

" Window navigation
nnoremap <leader>h <C-w>h<CR>                    " Navigate left
nnoremap <leader>j <C-w>j<CR>                    " Navigate down
nnoremap <leader>k <C-w>k<CR>                    " Navigate up
nnoremap <leader>l <C-w>l<CR>                    " Navigate right

" ------------------------------------------------------------------------------
" ConEmu Config
" ------------------------------------------------------------------------------
if !empty($CONEMUBUILD)
    set term=xterm
    set termencoding=utf8
    set t_Co=16
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
endif

" ------------------------------------------------------------------------------
" Vundle Config
" ------------------------------------------------------------------------------
filetype off

" Install Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Bundle 'gmarik/Vundle.vim'

" Cool plugins
Bundle 'scrooloose/nerdtree'
Bundle 'Xuyuanp/nerdtree-git-plugin'
Bundle 'ctrlpvim/ctrlp.vim'
Bundle 'ntpeters/vim-better-whitespace'
Bundle 'tpope/vim-surround'
Bundle 'jiangmiao/auto-pairs'
Bundle 'scrooloose/syntastic'
Bundle 'Valloric/YouCompleteMe'
Bundle 'bling/vim-airline'
Bundle 'godlygeek/tabular'
Bundle 'terryma/vim-multiple-cursors'

" Visuals
Bundle 'altercation/vim-colors-solarized'
Bundle 'vim-airline/vim-airline-themes'

" Commenting
Bundle 'tomtom/tlib_vim.git'
Bundle 'tomtom/tcomment_vim.git'

" Javascript
Bundle 'othree/yajs.vim'
Bundle 'othree/javascript-libraries-syntax.vim'

call vundle#end()            " Required
filetype plugin indent on    " Required

" ------------------------------------------------------------------------------
" Solarized Theme (Must be set after Vundle)
" ------------------------------------------------------------------------------
set background=dark
colorscheme solarized
