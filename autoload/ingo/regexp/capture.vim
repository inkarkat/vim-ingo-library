" ingo/regexp/capture.vim: Functions to work with capture groups.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#capture#MakeNonCapturing( pattern )
"******************************************************************************
"* PURPOSE:
"   Convert all capturing groups in a:pattern into non-capturing groups.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   Converted regular expression without any capturing groups.
"******************************************************************************
    return substitute(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\(', '\\%(', 'g')
endfunction
function! ingo#regexp#capture#MakeCapturing( pattern )
"******************************************************************************
"* PURPOSE:
"   Convert all non-capturing groups in a:pattern into capturing groups.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression.
"* RETURN VALUES:
"   Converted regular expression without any non-capturing groups.
"******************************************************************************
    return substitute(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%(', '\\(', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
