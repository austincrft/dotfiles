" Tabs
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

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
