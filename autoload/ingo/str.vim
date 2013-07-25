" ingo/str.vim: String functions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	19-Jun-2013	file creation

function! ingo#str#Trim( string )
"******************************************************************************
"* PURPOSE:
"   Remove all leading and trailing whitespace from a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Text.
"* RETURN VALUES:
"   a:string with leading and trailing whitespace removed.
"******************************************************************************
    return substitute(a:string, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
