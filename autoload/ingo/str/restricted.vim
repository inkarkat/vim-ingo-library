" ingo/str/restricted.vim: Functions to restrict arbitrary strings to certain classes.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.017.001	28-Feb-2014	file creation

function! ingo#str#restricted#ToShortCharacterwise( expr, ... )
"******************************************************************************
"* PURPOSE:
"   Restrict an arbitrary string a:expr to a short, readable text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Source text.
"   a:default   Text to be used when the source text doesn't fit the
"		requirements of being "short". Defaults to the empty string.
"   a:maxCharacterNum   Maximum width to be considered "short". Defaults to
"			'textwidth' / 80 screen cells.
"* RETURN VALUES:
"   If a:expr is short enough and does not contain multi-line text, return
"   a:expr. Else return nothing / the a:default.
"******************************************************************************
    let l:default = (a:0 ? a:1 : '')
    let l:maxCharacterNum = (a:0 > 1 ? a:2 : (&textwidth > 0 ? &textwidth : 80))

    return (a:expr =~# '\n' || ingo#compat#strchars(a:expr) > l:maxCharacterNum ? l:default : a:expr)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
