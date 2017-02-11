" Syntax
let python_highlight_all=1

" Folds
set foldmethod=indent
set foldlevel=2
set foldnestmax=2

" Make
" set makeprg=python\ %

" Tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79

" Mappings
nnoremap <leader>md :call jedi#show_documentation()<CR>|
nnoremap <leader>mg :call jedi#goto_assignments()<CR>|
nnoremap <leader>mfu :call jedi#usages()<CR>|
nnoremap <leader>mr :call jedi#rename()<CR>|
