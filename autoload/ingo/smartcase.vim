" ingo/smartcase.vim: Functions for SmartCase searches.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.021.001	20-Jun-2014	file creation

function! ingo#smartcase#IsSmartCasePattern( pattern )
    return (a:pattern =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\c' && a:pattern =~# '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\A\\[?=]')
endfunction
function! ingo#smartcase#FromPattern( pattern )
    let l:pattern = a:pattern

    " Make all non-alphabetic delimiter characters and whitespace optional. As
    " the substitution separator and backslash are escaped, they must be handled
    " separately.
    let l:pattern = substitute(l:pattern, '\\\@!\A\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[/\\]', '\\A\\=', 'g')
    " Allow delimiters between CamelCase fragments to catch all variants.
    let l:pattern = substitute(l:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\(\l\)\(\u\)', '\1\\A\\=\2', 'g')

    return '\c' . l:pattern
endfunction
function! ingo#smartcase#Undo( smartCasePattern )
    return substitute(a:smartCasePattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\(c\|A\\[?=]\)', '', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
