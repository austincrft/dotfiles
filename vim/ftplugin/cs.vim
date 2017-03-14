" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <leader>md :OmniSharpDocumentation<CR>|
nnoremap <leader>mg :OmniSharpGotoDefinition<CR>|
nnoremap <leader>mr :OmniSharpStopServer<CR><bar>:OmniSharpStartServer<CR>|
nnoremap <leader>mff :OmniSharpFixIssue<CR>|
nnoremap <leader>mfi :OmniSharpFindImplementations<CR>|
nnoremap <leader>mfu :OmniSharpFindUsages<CR>|
nnoremap <leader>mt :OmniSharpTypeLookup<CR>|
nnoremap <leader>mT :OmniSharpRunAllTests<CR>|
" Fold methods
nnoremap <leader>fm ZMzrzr<CR>|
nnoremap [m :OmniSharpNavigateUp<CR>|
nnoremap ]m :OmniSharpNavigateDown<CR>|
