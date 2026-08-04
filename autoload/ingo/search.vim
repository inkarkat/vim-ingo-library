" ingo/search.vim: Functions for searching.
"
" DEPENDENCIES:
"
" Copyright: (C) 2026 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#search#IsBufferContains( pattern, ... )
    return call('search', [a:pattern, 'cnw'] + a:000)
endfunction
function! ingo#search#FirstPatternThatMatchesInBuffer( patterns )
"******************************************************************************
"* PURPOSE:
"   Search for matches of any of a:patterns in the buffer, and return the first
"   pattern that matches.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:patterns  List of regular expressions.
"* RETURN VALUES:
"   First pattern from a:patterns that matches somewhere in the current buffer,
"   or empty String.
"******************************************************************************
    for l:pattern in a:patterns
	if ingo#search#IsBufferContains(l:pattern)
	    return l:pattern
	endif
    endfor
    return ''
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
