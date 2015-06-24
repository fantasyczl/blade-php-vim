" Language: Blade


if exists("b:did_indent")
    finish
endif


setlocal indentexpr=GetBladeIndent(v:lnum)

setlocal indentkeys=o,O<Return>,<>>,{,},!^F,0{,0},0),:,!^F,e,*<Return>,=?>,=<?,=*/


function! GetBladeIndent(lnum)
    let lnum = prevnonblank(a:lnum - 1)
    
    if lnum == 0
        return 0
    endif

    return indent(lnum)

endfunction
