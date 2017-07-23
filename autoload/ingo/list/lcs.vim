" autoload/ingo/list/lcs.vim: Functions to find longest common substring(s).
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/str/split.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#list#lcs#FindLongestCommon( strings, ... )
"******************************************************************************
"* PURPOSE:
"   Find the (first) longest common substring that occurs in each of a:strings.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strings   List of strings.
"   a:minimumLength Minimum substring length; default 1.
"* RETURN VALUES:
"   Longest string that occurs in all of a:strings, or empty string if there's
"   no commonality at all.
"******************************************************************************
    let l:minimumLength = (a:0 ? a:1 : 1)
    let l:pos = 0
    let l:maxMatchLen = 0
    let l:maxMatch = ''

    while 1
	let [l:match, l:startPos, l:endPos] = matchstrpos(
	\   join(a:strings + [''], "\n"),
	\   printf('^[^\n]\{-}\zs\([^\n]\{%d,}\)\ze[^\n]\{-}\n\%([^\n]\{-}\1[^\n]*\n\)\{%d}$', l:minimumLength, len(a:strings) - 1),
	\   l:pos
	\)
	if l:startPos == -1
	    break
	endif
	let l:pos = l:endPos
"****D echomsg '****' l:match
	let l:matchLen = ingo#compat#strchars(l:match)
	if l:matchLen > l:maxMatchLen
	    let l:maxMatch = l:match
	    let l:maxMatchLen = l:matchLen
	endif
    endwhile

    return l:maxMatch
endfunction

function! ingo#list#lcs#FindAllCommon( strings, ... )
"******************************************************************************
"* PURPOSE:
"   Find all common substrings that occur in each of a:strings.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:strings   List of strings.
"   a:minimumLength Minimum substring length; default 1.
"* RETURN VALUES:
"   [
"	[prefix1, prefix2, ...], [middle1, middle2, ...], ..., [suffix1, suffix2, ...],
"	[commonBetweenPrefixAndMiddle, ..., commonBetweenMiddleAndSuffix]
"   ]
"   The second List always contains one element less than the first; its
"   elements are meant to go between those of the first List.
"   If all strings start or end with a common substring, [prefix1, prefix2, ...]
"   / [suffix1, suffix2, ...] is the empty List [].
"******************************************************************************
    let l:minimumLength = (a:0 ? a:1 : 1)

    let l:common = ingo#list#lcs#FindLongestCommon(a:strings, l:minimumLength)
    if empty(l:common)
	return [[a:strings], []]
    endif

    let [l:prefixes, l:suffixes] = s:Split(a:strings, l:common)

    let [l:prefixDiffering, l:prefixCommon] = ingo#list#lcs#FindAllCommon(l:prefixes, l:minimumLength)
    let [l:suffixDiffering, l:suffixCommon] = ingo#list#lcs#FindAllCommon(l:suffixes, l:minimumLength)

    return [
    \   l:prefixDiffering + l:suffixDiffering,
    \   filter(l:prefixCommon + [l:common ] + l:suffixCommon, '! empty(v:val)')
    \]
endfunction
function! s:Split( strings, common )
    let l:prefixes = []
    let l:suffixes = []

    for l:string in a:strings
	let [l:prefix, l:suffix] = ingo#str#split#StrFirst(l:string, a:common)
	call add(l:prefixes, l:prefix)
	call add(l:suffixes, l:suffix)
    endfor

    return [s:Shorten(l:prefixes), s:Shorten(l:suffixes)]
endfunction
function! s:Shorten( list )
    return (empty(filter(copy(a:list), '! empty(v:val)')) ?
    \   [] :
    \   a:list
    \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
