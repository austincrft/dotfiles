" Tabs
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

function! FormatJson()
    execute "%!python -m json.tool"
endfunction
command! -nargs=0 -complete=command FormatJson call FormatJson()
