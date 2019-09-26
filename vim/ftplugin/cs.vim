" Set encoding
setlocal bomb
setlocal fileencoding=utf8

" Line length
setlocal colorcolumn=100
setlocal textwidth=100

" Mappings
nnoremap <buffer> <leader>fm zMzrzr

nnoremap <buffer> [m :OmniSharpNavigateUp<CR>
nnoremap <buffer> ]m :OmniSharpNavigateDown<CR>

nnoremap <buffer> <C-]> :OmniSharpGotoDefinition<CR>

nnoremap <buffer> <leader>mm :OmniSharpGlobalCodeCheck<CR>
nnoremap <buffer> <leader>md :OmniSharpDocumentation<CR>
nnoremap <buffer> <leader>mfu :OmniSharpFindUsages<CR>
nnoremap <buffer> <leader>mfx :OmniSharpFixUsings<CR>
nnoremap <buffer> <leader>mfi :OmniSharpFindImplementations<CR>
nnoremap <buffer> <leader>mfm :OmniSharpFindMembers<CR>
nnoremap <buffer> <leader>mt :OmniSharpTypeLookup<CR>
nnoremap <buffer> <leader>mr :OmniSharpRename<CR>
nnoremap <buffer> <leader>= :OmniSharpCodeFormat<CR>
