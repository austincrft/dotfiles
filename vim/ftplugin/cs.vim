" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <buffer> <leader>md :OmniSharpDocumentation<CR>|
nnoremap <buffer> <leader>mg :OmniSharpGotoDefinition<CR>|
nnoremap <buffer> <leader>mr :OmniSharpStopServer<CR><bar>:OmniSharpStartServer<CR>|
nnoremap <buffer> <leader>mff :OmniSharpFixIssue<CR>|
nnoremap <buffer> <leader>mfi :OmniSharpFindImplementations<CR>|
nnoremap <buffer> <leader>mfu :OmniSharpFindUsages<CR>|
nnoremap <buffer> <leader>mt :OmniSharpTypeLookup<CR>|
nnoremap <buffer> <leader>mT :OmniSharpRunAllTests<CR>|
" Fold methods
nnoremap <buffer> <leader>fm zMzrzr<CR>|
nnoremap <buffer> [m :OmniSharpNavigateUp<CR>|
nnoremap <buffer> ]m :OmniSharpNavigateDown<CR>|
