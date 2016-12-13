" ingo/str/find.vim: Functions to find stuff in a string.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	14-Dec-2016	file creation

function! ingo#str#find#NotContaining( string, characterSet )
"******************************************************************************
"* PURPOSE:
"   Find the first character of a:characterSet not contained in a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Source string to be inspected.
"   a:characterSet  String or List of candidate characters.
"* RETURN VALUES:
"   First character in a:characterSet that is not contained in a:string, or
"   empty string if all characters are contained.
"******************************************************************************
    for l:candidate in (type(a:characterSet) == type([]) ? a:characterSet : split(a:characterSet, '\zs'))
	if stridx(a:string, l:candidate) == -1
	    return l:candidate
	endif
    endfor
    return ''
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
