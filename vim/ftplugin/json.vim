function! FormatJson()
    execute "%!python -m json.tool"
endfunction
command! -nargs=0 -complete=command FormatJson call FormatJson()
