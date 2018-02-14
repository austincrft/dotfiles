" Tabs
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

" Formatting
set equalprg=xmllint\ --format\ -

" Mappings
vnoremap <buffer> <leader>me :call EscapeXml(0)<CR>| " Escape character codes
vnoremap <buffer> <leader>mu :call EscapeXml(1)<CR>| " Unescape character codes
