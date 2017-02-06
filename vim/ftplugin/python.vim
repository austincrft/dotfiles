" Syntax
let python_highlight_all=1

" Make
setlocal makeprg=python\ %

" Line length
setlocal colorcolumn=79
setlocal textwidth=79

" Mappings
nnoremap <leader>md :YcmCompleter GetDoc<CR>|
nnoremap <leader>mg :YcmCompleter GoTo<CR>|
nnoremap <leader>mr :YcmCompleter RestartServer<CR>|
