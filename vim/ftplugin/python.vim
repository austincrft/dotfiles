" Syntax
let python_highlight_all=1

" Line length
setlocal colorcolumn=79
setlocal textwidth=79

" Mappings
nnoremap <buffer> <leader>mm :AsyncRunWithQf python3 %<CR>|
nnoremap <buffer> <leader>md :call jedi#show_documentation()<CR>|
nnoremap <buffer> <leader>mg :call jedi#goto_assignments()<CR>|
nnoremap <buffer> <leader>mfu :call jedi#usages()<CR>|
nnoremap <buffer> <leader>mr :call jedi#rename()<CR>|
