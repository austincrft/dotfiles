" Syntax
let python_highlight_all=1

" Make
setlocal makeprg=python\ %

" Line length
setlocal colorcolumn=79
setlocal textwidth=79

" Mappings
nnoremap <buffer> <leader>md :call jedi#show_documentation()<CR>|
nnoremap <buffer> <leader>mg :call jedi#goto_assignments()<CR>|
nnoremap <buffer> <leader>mfu :call jedi#usages()<CR>|
nnoremap <buffer> <leader>mr :call jedi#rename()<CR>|
