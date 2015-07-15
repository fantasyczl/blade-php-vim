" Language: Blade


if exists("b:did_indent")
    finish
endif

runtime! indent/html.vim
"silent! unlet b:did_indent
runtime! indent/php.vim

let b:did_indent = 1

setlocal indentexpr=GetBladeIndent()

setlocal indentkeys=o,O<Return>,<>>,{,},!^F,0{,0},0),:,!^F,e,*<Return>,=?>,=<?,=*/,@


function! GetBladeIndent()
    let lnum = v:lnum
    echo "lnum = " lnum
    let preNum = prevnonblank(lnum - 1)
    echo "preNum = " preNum
    
    if preNum == 0
        return 0
    endif

	let indent = HtmlIndent()
    echo "indent = " indent

    if indent == -1
        let preLine = getline(preNum)
        let curLine = getline(lnum)
        echo "curLine = " curLine

        if preLine =~? '^\s*@end'
            let indent = indent(preNum)
        elseif preLine =~? '^\s*@'
            let indent = indent(preNum) + &sw
        else
            if curLine =~? '^\s*@end' && preLine !~? '^\s*@'
                let indent = indent(preNum) 
            else
                let indent = indent(preNum)
            endif
        endif

        silent! unlet preLine
        silent! unlet curLine
    endif

    return indent
endfunc


function! BladeTagOpen(lnum)
endfun

function! TestBlade()
    if getline(a:lnum) =~ '\c</pre>' 
                \ || 0 < searchpair('\c<pre>', '', '\c</pre>', 'nWb')
                \ || 0 < searchpair('\c<pre>', '', '\c</pre>', 'nW')
        return -1
    endif

    if getline(lnum) =~ '\c</pre>'
        let preline = prevnonblank(search('\c<pre>', 'bW') - 1)
        if preline > 0
            return indent(preline)
        endif
    endif

    let ind = 1
    "let ind = HtmlIndentSum(lnum, -1)
    "echom "ind = " ind
    "let ind = ind + HtmlIndentSum(a:lnum, 0)

    echom "lnum = " lnum
    echom "indent(lnum) = " indent(lnum)
    return indent(lnum) + (&sw * ind)

endfunc

function! HtmlIndentOpen(lnum, pattern)
    let s = substitute('x'.getline(a:lnum)),
                \ '.\{-}\(\(<\)\('.a:pattern.'\)\>\)', "\1", 'g')
    let s = substitute(s, "[^\1].*$", '', '')
    return strlen(s)
endfun

function! HtmlIndentClose(lnum, pattern)
    let s = substitute('x'.getline(a:lnum)),
                \ '.\{-}\(\(<\)/\('.a:pattern.'\)\>>\)', "\1", 'g')
    let s = substitute(s, "[^\1].*$", '', '')
    return strlen(s)
endfunc

function! HtmlIndentOpenAlt(lnum)
    return strlen(substitute(getline(a:lnum), '[^{]\+', '', 'g'))
endfunc

function! HtmlIndentCloseAlt(lnum)
    return strlen(substitute(getline(a:lnum), '[^}]\+', '', 'g'))
endfunc

function! HtmlIndentSum(lnum, style)
    if a:style == match(getline(a:lnum), '^\s*</')
        if a:style == match(getline(a:lnum), '^\s*</\<\(' .g:html_indent_tags.'\)\>')
            let open = HtmlIndentOpen(a:lnum, g:html_indent_tags)
            let close = HtmlIndentClose(a:lnum, g:html_indent_tags)
            if 0 != open || 0 != close
                return open - close
            endif
        endif
    endif

    if '' != &syntax && 
                \ synIDattr(synID(a:lnum, 1, 1), 'name') =~ '\(css\|java\).*' &&
                \ synIDattr(synID(a:lnum, strlen(getline(a:lnum)), 1), 'name')
                \ =~ '\(css\|java\).*'
        if a:style == match(getline(a:lnum), '^\s*}')
            return HtmlIndentOpenAlt(a:lnum) - HtmlIndentCloseAlt(a:lnum)
        endif
    endif
    return 0
endfunc
