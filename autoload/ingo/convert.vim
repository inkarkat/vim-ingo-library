" ingo/convert.vim: Functions for type conversions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#convert#ToSingleLineString( expr ) abort
"******************************************************************************
"* PURPOSE:
"   Convert a:expr to a String that does not contain newline characters, but the
"   "\n" notation instead.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Variable (of arbitrary type, but likely String).
"* RETURN VALUES:
"   String.
"******************************************************************************
    return substitute(string(a:expr), '\n', "'.\"\\\\n\".'", 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
