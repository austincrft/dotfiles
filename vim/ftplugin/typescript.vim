" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <leader>mg :TsuquyomiDefinition<CR>|
nnoremap <leader>mr :TsuquyomiStartServer<CR><bar>:TsuquyomiStopServer<CR>|
nnoremap <leader>mfu :TsuquyomiReferences<CR>|
" Fold methods
nnoremap <leader>fm ZMzrzr<CR>|
