" Folds
set foldmethod=indent
set foldnestmax=3
set foldlevel=2
set foldlevelstart=2

" Tabs
set tabstop=2
set softtabstop=2
set shiftwidth=2
set textwidth=79

" Mappings
nnoremap <leader>md :OmniSharpDocumentation<CR>|
nnoremap <leader>mg :OmniSharpGotoDefinition<CR>|
nnoremap <leader>mr :OmniSharpStopServer<CR><bar>:OmniSharpStartServer<CR>|
nnoremap <leader>mfi :OmniSharpFixIssue<CR>|
nnoremap <leader>mfI :OmniSharpFindImplementations<CR>|
nnoremap <leader>mfu :OmniSharpFindUsages<CR>|
nnoremap <leader>mt :OmniSharpTypeLookup<CR>|
nnoremap [m :OmniSharpNavigateUp<CR>|
nnoremap ]m :OmniSharpNavigateDown<CR>|
