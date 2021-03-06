" Tabs
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <buffer> <leader>mg :TsuDefinition<CR>|
nnoremap <buffer> <leader>mfu :TsuReferences<CR>|
nnoremap <buffer> <leader>mfi :TsuImplementation<CR>|
nnoremap <buffer> <leader>mr :TsuRenameSymbol<CR>|
nnoremap <buffer> <leader>mt : <C-u>echo tsuquyomi#hint()<CR>
nnoremap <buffer> <leader>mf :TsuQuickFix<CR>

" Fold methods
nnoremap <buffer> <leader>fm zMzrzr<CR>|
