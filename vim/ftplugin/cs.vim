" Folds
set foldmethod=indent
set foldnestmax=3
set foldlevel=2
set foldlevelstart=2

" Tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set textwidth=79

" Mappings
nnoremap <leader>md :YcmCompleter GetDoc<CR>|        " Get Doc
nnoremap <leader>mg :YcmCompleter GoTo<CR>|          " Go To Definition
nnoremap <leader>mr :YcmCompleter RestartServer<CR>| " Restart Server
nnoremap <leader>mt :YcmCompleter GetType<CR>|       " Get Type
