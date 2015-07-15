" Language: Blade


if exists("b:current_syntax") && b:current_syntax == 'blade'
    finish
endif

runtime! syntax/php.vim
silent! unlet b:current_syntax

syn region bladeUnescapedEcho matchgroup=bladeEchoDelim start=/@\@<!\s*{!!/ end=/!!}\s*/ oneline contains=@phpClTop containedin=ALLBUT,bladeComment
syn region bladeEscapedEcho matchgroup=bladeEchoDelim start=/@\@<!\s*{{{\@!/ end=/}}\s*/ oneline contains=@phpClTop containedin=ALLBUT,bladeComment
syn region bladeEscapedEcho matchgroup=bladeEchoDelim start=/@\@<!\s*{{{{\@!/ end=/}}}/ oneline contains=@phpClTop containedin=ALLBUT,bladeComment

syn match bladeStructure /\s*@\(else\|empty\|endfor\|endforeach\|endforelse\|endif\|endpush\|endsection\|endunless\|endwhile\|overwrite\|show\|stop\)\>/

syn match bladeStructure /\s*@\(append\|choice\|each\|elseif\|extends\|for\|foreach\|forelse\|if\|include\|lang\|push\|section\|stack\|unless\|while\|yield\|\)\>\s*/ nextgroup=bladeParens

syn region bladeParens matchgroup=bladeParen start=/(/ end=/)/ contained contains=@bladeAll,@phpClTop

syn region bladeComments start=/\s*{{--/ end=/--}}/ contains=bladeComment keepend
syn match bladeComment /.*/ contained containedin=bladeComments

syn cluster bladeAll contains=bladeStructure,bladeParens

hi def link bladeComment        Comment
hi def link bladeEchoDelim      Delimiter
hi def link bladeParen          Delimiter
hi def link bladeStructure      Keyword


if !exists('b:current_syntax')
    let b:current_syntax = 'blade'
endif
