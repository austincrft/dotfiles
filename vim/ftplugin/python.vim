" Syntax
let python_highlight_all=1

" Folds
set foldmethod=indent
set foldlevel=2
set foldnestmax=2

" Make
set makeprg=python\ %

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79

" Mappings
nnoremap <leader>md :YcmCompleter GetDoc<CR>|
nnoremap <leader>mg :YcmCompleter GoTo<CR>|
nnoremap <leader>mr :YcmCompleter RestartServer<CR>|
