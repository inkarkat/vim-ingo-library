" ingo/regexp/collection.vim: Functions around handling collections in regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016-2018 Ingo Karkat
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
let s:save_cpo = &cpo
set cpo&vim

function! ingo#regexp#collection#Expr( ... )
"******************************************************************************
"* PURPOSE:
"   Returns a regular expression that matches any collection atom.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   The exact pattern can be influenced by the following options:
"   a:option.isBarePattern          Flag whether to return a bare pattern that
"                                   does not make any assertions on what's
"                                   before the [. This overrides the following
"                                   options. Default false.
"   a:option.isIncludeEolVariant    Flag whether to include the /\_[]/ variant as
"                                   well. Default true.
"   a:option.isMagic                Flag whether 'magic' is set, and [] is used
"                                   instead of \[]. Default true.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isBarePattern = get(l:options, 'isBarePattern', 0)
    let l:isIncludeEolVariant = get(l:options, 'isIncludeEolVariant', 1)
    let l:isMagic = get(l:options, 'isMagic', 1)

    let l:prefixExpr = (l:isBarePattern ?
    \   '' :
    \   '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!' . (l:isMagic ?
    \       (l:isIncludeEolVariant ? '\%(\\_\)\?' : '') :
    \       (l:isIncludeEolVariant ? '\\_\?' : '\\')
    \   )
    \)

    return l:prefixExpr . '\[\%(\]$\)\@!\]\?\%(\[:\a\+:\]\|\[=.\{-}=\]\|\[\..\.\]\|[^\]]\)*\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\]'
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

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
