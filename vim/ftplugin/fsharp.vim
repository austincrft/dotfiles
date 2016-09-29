" Folds
set foldmethod=indent
set foldnestmax=3
set foldlevel=2
set foldlevelstart=2

" Mappings
vnoremap <leader>me :FsiEval<CR>| " Visual
nnoremap <leader>me :FsiEval<CR>| " Normal
nnoremap <leader>ms :FsiShow<CR>|
nnoremap <leader>mr :FsiReset<CR>|
nnoremap <leader>mc :FsiClear<CR>|
nnoremap <leader>mT :FSharpRunTests<CR>|
