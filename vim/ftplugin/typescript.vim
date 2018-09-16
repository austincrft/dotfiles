" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <buffer> <leader>mg :TsuDefinition<CR>|
nnoremap <buffer> <leader>mfu :TsuReferences<CR>|
nnoremap <buffer> <leader>mfi :TsuImplementation<CR>|
nnoremap <buffer> <leader>mfr :TsuRenameSymbol<CR>|
" Fold methods
nnoremap <buffer> <leader>fm zMzrzr<CR>|
