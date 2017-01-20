" Tabs
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4

" Mappings
nnoremap <leader>md :OmniSharpDocumentation<CR>|
nnoremap <leader>mg :OmniSharpGotoDefinition<CR>|
nnoremap <leader>mr :OmniSharpStopServer<CR><bar>:OmniSharpStartServer<CR>|
nnoremap <leader>mfi :OmniSharpFixIssue<CR>|
nnoremap <leader>mfI :OmniSharpFindImplementations<CR>|
nnoremap <leader>mfu :OmniSharpFindUsages<CR>|
nnoremap <leader>mt :OmniSharpTypeLookup<CR>|
nnoremap <leader>mT :OmniSharpRunAllTests<CR>|
nnoremap [m :OmniSharpNavigateUp<CR>|
nnoremap ]m :OmniSharpNavigateDown<CR>|
