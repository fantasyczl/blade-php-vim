" Language: Blade
" Author:	fantasyczl <czilong0618@gmail.com>
" Last Change:  2015 July 26th
" Version:  0.1


if exists("b:did_indent")
    finish
endif

runtime! indent/html.vim
"silent! unlet b:did_indent
runtime! indent/php.vim

let b:did_indent = 1

let b:startList = []
let b:centerList = []
let b:endList = []

setlocal indentexpr=GetBladeIndent()

setlocal indentkeys=o,O<Return>,<>>,{,},!^F,0{,0},0),:,!^F,e,*<Return>,=?>,=<?,=*/,@


function! GetBladeIndent()
    let lnum = v:lnum
    let preNum = prevnonblank(lnum - 1)
    
    if preNum == 0
        return 0
    endif

	let indent = HtmlIndent()

    let preLine = getline(preNum)
    let curLine = getline(lnum)

    if IsTagStart(preLine) == 1
        let indent += &sw
    endif

    if IsTagEnd(curLine) == 1
        let indent -= &sw
    endif

    silent! unlet preLine
    silent! unlet curLine

    return indent
endfunc


function! IsTagStart(line)
    if a:line =~? '^\s*@if' || a:line =~? '^\s*@else' || a:line =~? '^\s*@for' || a:line =~? '^\s*@sect'
        return 1
    endif

    return 0
endfun

function! IsTagEnd(line)
    if a:line =~? '^\s*@end' || a:line =~? '^\s*@stop' || a:line =~? '^\s*@else'
        return 1
    endif

    return 0
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
