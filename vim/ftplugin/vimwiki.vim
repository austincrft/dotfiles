" Add title in the following format: # YYYY-DD-MM
function! AddTitle()
    execute "norm! gg0\"%PvbhdbbbbbhvBd0i# "
endfunction
command! -nargs=0 -complete=command AddTitle call AddTitle()


" Map to obscure thing so it doesn't override my buffer nav mappings
nmap <buffer> <C-J> <Plug>VimwikiNextLink
nmap <buffer> <C-K> <Plug>VimwikiPrevLink
