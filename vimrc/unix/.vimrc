" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" ================ General Config ====================
"
"
set relativenumber              "Relative numbering
set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

"turn on syntax highlighting
syntax on

" The mapleader has to be set before vundle starts loading all
" the plugins.
let mapleader = ","
nmap <Leader>rxm :ExtractMethod<Enter>

" Copy the absolute path of the current file to the clipboard
nmap <Leader>cf :silent !echo -n %:p \| pbcopy<Enter>

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Indentation ======================

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

set nowrap       "Don't wrap lines
set linebreak    "Wrap lines at convenient points

filetype off
" Install Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Cool plugins
Bundle 'scrooloose/nerdtree'
Bundle 'Xuyuanp/nerdtree-git-plugin'
Bundle 'ctrlpvim/ctrlp.vim'
Bundle 'tommcdo/vim-exchange.git'
Bundle 'ntpeters/vim-better-whitespace'
Bundle 'tpope/vim-surround'
Bundle 'jiangmiao/auto-pairs'
Bundle 'scrooloose/syntastic'
Bundle 'vim-scripts/CursorLineCurrentWindow'
Bundle 'Valloric/YouCompleteMe'
Plugin 'bling/vim-airline'

" Visuals
Bundle 'altercation/vim-colors-solarized'

" Commenting
Bundle "tomtom/tlib_vim.git"
Bundle "tomtom/tcomment_vim.git"

" Javascript
Bundle "othree/yajs.vim"
Bundle "othree/javascript-libraries-syntax.vim"

" Ruby
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-endwise'


call vundle#end()            " required
filetype plugin indent on    " required

syntax enable

" Solarized theme
let g:solarized_termtrans = 1
set background=dark
colorscheme solarized

if has("gui_running")
"tell the term has 256 colors
  set t_Co=256
end

" Better search
set hlsearch
set incsearch

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" grep word under cursor
nnoremap <Leader>g :grep! "\b<C-R><C-W>\b"<CR>:cw<CR><CR>

" Move normally between wrapped lines
nmap j gj
nmap k gk

" always show status line
set laststatus=2

" Enable filetype plugins for vim-textobj-rubyblock
if has("autocmd")
  filetype indent plugin on
endif

autocmd FocusLost * silent! wa " Automatically save file
set scrolloff=5 " Keep 5 lines below and above the cursor
set cursorline
set laststatus=2
let mapleader = ','

" Activate  Airline smarter tab line
let g:airline#extensions#tabline#enabled = 1

" Map Esc key to jj
:imap jj <Esc>

" Bind Ctrl+<movement> keys to move around the windows
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" Easier moving of code blocks
vnoremap < <gv  " better indentation
vnoremap > >gv  " better indentation
noremap <C-S-h> :bp<Enter>
noremap <C-S-l> :bn<Enter>
noremap <Leader>t :CtrlP<Enter>

" Force HTML Django syntax on for *.html files
au BufNewFile,BufRead *.html set filetype=htmldjango
