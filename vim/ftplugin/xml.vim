" Tabs
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

" Mappings
vnoremap <leader>me :call EscapeXml(0)<CR>| " Escape character codes
vnoremap <leader>mu :call EscapeXml(1)<CR>| " Unescape character codes
