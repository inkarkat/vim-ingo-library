" ingo/str/split.vim: Functions for splitting strings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#str#split#StrFirst( expr, str )
"******************************************************************************
"* PURPOSE:
"   Split a:expr into the text before and after the first occurrence of a:str.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be split.
"   a:str   The literal text to split on.
"* RETURN VALUES:
"   Tuple of [beforeStr, afterStr].
"   When there's no occurrence of a:str, the returned tuple is [a:expr, ''].
"******************************************************************************
    let l:startIdx = stridx(a:expr, a:str)
    if l:startIdx == -1
	return [a:expr, '']
    endif

    let l:endIdx = l:startIdx + len(a:str)
    return [strpart(a:expr, 0, l:startIdx), strpart(a:expr, l:endIdx)]
endfunction
function! ingo#str#split#MatchFirst( expr, pattern )
"******************************************************************************
"* PURPOSE:
"   Split a:expr into the text before and after the first match of a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Text to be split.
"   a:pattern	The pattern to split on; 'ignorecase' applies.
"* RETURN VALUES:
"   Tuple of [beforeMatch, matchedText, afterMatch].
"   When there's no match of a:pattern, the returned tuple is [a:expr, '', ''].
"******************************************************************************
    let l:startIdx = match(a:expr, a:pattern)
    if l:startIdx == -1
	return [a:expr, '', '']
    endif

    let l:endIdx = matchend(a:expr, a:pattern)
    return [strpart(a:expr, 0, l:startIdx), strpart(a:expr, l:startIdx, l:endIdx - l:startIdx), strpart(a:expr, l:endIdx)]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
