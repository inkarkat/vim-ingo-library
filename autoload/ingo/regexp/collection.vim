" ingo/regexp/collection.vim: Functions around handling collections in regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.003	15-May-2017	ENH: ingo#regexp#collection#LiteralToRegexp():
"				Support inverted collection via optional
"				a:isInvert flag.
"   1.029.002	23-Jan-2017	Add ingo#regexp#collection#Expr().
"   1.027.001	30-Sep-2016	file creation

function! ingo#regexp#collection#Expr()
"******************************************************************************
"* PURPOSE:
"   Returns a regular expression that matches any collection atom.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return '\[\%(\]$\)\@!\]\?\%(\[:\a\+:\]\|\[=.\{-}=\]\|\[\..\.\]\|[^\]]\)*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\]'
endfunction

function! ingo#regexp#collection#GetSpecialCharacters()
    return '[]-^\'
endfunction

function! ingo#regexp#collection#EscapeLiteralCharacters( text )
    " XXX: If we escape [ as \[, all backslashes will be matched, too.
    " Instead, we have to place [ last in the collection: [abc[].
    if a:text =~# '\['
	return escape(substitute(a:text, '\[', '', 'g'), ingo#regexp#collection#GetSpecialCharacters()) . '['
    else
	return escape(a:text, ingo#regexp#collection#GetSpecialCharacters())
    endif
endfunction

function! ingo#regexp#collection#LiteralToRegexp( text, ... )
    let l:isInvert = (a:0 && a:1)
    return '[' . (l:isInvert ? '^' : '') . ingo#regexp#collection#EscapeLiteralCharacters(a:text) . ']'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
