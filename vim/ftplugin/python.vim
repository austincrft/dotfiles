" Syntax
let python_highlight_all=1

" Make
setlocal makeprg=python\ %

" Line length
setlocal colorcolumn=79
setlocal textwidth=79

" Mappings
nnoremap <leader>md :call jedi#show_documentation()<CR>|
nnoremap <leader>mg :call jedi#goto_assignments()<CR>|
nnoremap <leader>mfu :call jedi#usages()<CR>|
nnoremap <leader>mr :call jedi#rename()<CR>|
