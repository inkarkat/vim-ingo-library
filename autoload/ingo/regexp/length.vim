" ingo/regexp/length.vim: Functions to compare the length of regular expression matches.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/list/split.vim autoload script
"   - ingo/regexp/magic.vim autoload script
"   - ingo/regexp/split.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:OverallMinMax( minMaxList )
    let l:minLengths = map(copy(a:minMaxList), 'v:val[0]')
    let l:maxLengths = map(copy(a:minMaxList), 'v:val[1]')
    return [min(l:minLengths), max(maxLengths)]
endfunction
function! ingo#regexp#length#Project( pattern )
"******************************************************************************
"* PURPOSE:
"   Estimate the number of characters that a:pattern will match. Of course, this
"   works best if the pattern specifies a literal match or only has fixed-width
"   atoms.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   Regular expression to analyze.
"* RETURN VALUES:
"   List of [minLength, maxLength]. For complex expressions or unbounded multis
"   like |/*| , assumes a minimum of 0 and a maximum of 0x7FFFFFFF.
"******************************************************************************
    let l:branches = ingo#regexp#split#TopLevelBranches(a:pattern)
    let l:minMaxBranches = map(
    \   l:branches,
    \   's:ProjectBranch(v:val)'
    \)
    return s:OverallMinMax(l:minMaxBranches)
endfunction
function! s:ProjectBranch( pattern )
    let l:patternMultis =
    \   ingo#list#split#ChunksOf(
    \       ingo#collections#SplitKeepSeparators(
    \           a:pattern,
    \           '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\*\|\\[+=?]\|\\{-\?\d*,\?\d*}\|\\@\%(>\|=\|!\|<=\|<!\)\)',
    \           1
    \       ),
    \       2, ''
    \   )

    let l:minMaxMultis = map(
    \   filter(
    \       l:patternMultis,
    \       'v:val !=# ["", ""]'
    \   ),
    \   's:ProjectMultis(v:val[0], v:val[1])'
    \)

    return s:OverallMinMax(l:minMaxMultis)
endfunction
function! s:ProjectMultis( pattern, multi )
    let [l:minLength, l:maxLength] = s:ProjectPattern(a:pattern)
    let [l:minMultiplier, l:maxMultiplier] = s:ProjectMulti(a:multi)

    return [l:minLength * l:minMultiplier, l:maxLength * l:maxMultiplier]
endfunction
function! s:ProjectPattern( pattern )
    return [len(a:pattern), len(a:pattern)]
endfunction
function! s:ProjectMulti( multi )
    if empty(a:multi)
	return [1, 1]
    elseif a:multi ==# '*'
	return [0, 0x7FFFFFFF]
    elseif a:multi ==# '\+'
	return [1, 0x7FFFFFFF]
    elseif a:multi ==# '\?'
	return [0, 1]
    elseif a:multi =~# '^\\{'
	let l:range = matchstr(a:multi, '^\\{-\?\zs[[:digit:],]*\ze}$')
	if l:range ==# a:multi | throw 'ASSERT: Invalid multi syntax' | endif
	if l:range =~# ','
	    let l:rangeNumbers = split(l:range, ',', 1)
	    return [
	    \   empty(l:rangeNumbers[0]) ? 0 : str2nr(l:rangeNumbers[0]),
	    \   empty(l:rangeNumbers[1]) ? 0x7FFFFFFF : str2nr(l:rangeNumbers[1])
	    \]
	else
	    return (empty(l:range) ?
	    \   [0, 0x7FFFFFFF] :
	    \   [str2nr(l:range), str2nr(l:range)]
	    \)
	endif
    elseif a:multi ==# '\@>'
	return [1, 1]
    elseif a:multi =~# '^\\@'
	return [0, 0]
    else
	throw 'ASSERT: Unhandled multi: ' . string(a:multi)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
