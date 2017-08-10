" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <buffer> <leader>mg :TsuquyomiDefinition<CR>|
nnoremap <buffer> <leader>mr :TsuquyomiStartServer<CR><bar>:TsuquyomiStopServer<CR>|
nnoremap <buffer> <leader>mfu :TsuquyomiReferences<CR>|
" Fold methods
nnoremap <buffer> <leader>fm zMzrzr<CR>|
