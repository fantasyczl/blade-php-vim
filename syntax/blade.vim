" Language: Blade


if exists("b:current_syntax")
    finish
endif

runtime! syntax/php.vim


if !exists("b:current_syntax")
    let b:current_syntax = "blade"
endif
