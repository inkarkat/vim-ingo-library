" subs/BraceCreation.vim: Condense multiple strings into a Brace Expression like in Bash.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/list/lcs.vim autoload script
"   - ingo/list/sequence.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	12-Aug-2017	file creation
let s:save_cpo = &cpo
set cpo&vim

function! subs#BraceCreation#Do( text, ... )
"******************************************************************************
"* PURPOSE:
"   Split a:text into WORDs (or on a:separatorPattern), extract common
"   substrings, and turn these into a (shorter) Brace Expression, like in Bash.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Source text with multiple strings.
"   a:separatorPattern  Regular expression to separate the source text into
"			strings. Defaults to whitespace.
"* RETURN VALUES:
"   Brace Expression.
"******************************************************************************
    let l:separatorPattern = (a:0 ? a:1 : '\_s\+')

    let l:strings = split(a:text, l:separatorPattern)
    if len(l:strings) <= 1
	throw 'Only one string'
    endif

    let [l:distinctLists, l:commons] = ingo#list#lcs#FindAllCommon(l:strings)

    return s:Join(l:distinctLists, l:commons)
endfunction
function! s:Join( distinctLists, commons )
    let l:result = []
    while ! empty(a:distinctLists) || ! empty(a:commons)
	if ! empty(a:distinctLists)
	    let l:distinctList = remove(a:distinctLists, 0)
	    let l:creation = s:Create(l:distinctList)[0]
	    if ! empty(l:creation)
		call add(l:result, '{' . l:creation . '}')
	    endif
	endif

	if ! empty(a:commons)
	    call add(l:result, remove(a:commons, 0))
	endif
    endwhile

    return join(l:result, '')
endfunction
function! s:Create( distinctList )
    if empty(a:distinctList)
	return ['', 0]
    endif

    let [l:sequenceLen, l:stride] = ingo#list#sequence#FindNumerical(a:distinctList)
    if l:sequenceLen <= 2 || ! ingo#list#Matches(a:distinctList[0 : l:sequenceLen - 1], '^\d\+$')
	let [l:sequenceLen, l:stride] = ingo#list#sequence#FindCharacter(a:distinctList)
    endif
    if l:sequenceLen > 2
	let l:result = a:distinctList[0] . '..' . a:distinctList[l:sequenceLen - 1] .
	\   (ingo#compat#abs(l:stride) == 1 ? '' : '..' . l:stride)

	if l:sequenceLen < len(a:distinctList)
	    " Search for further sequences in the surplus elements. If this is a
	    " sequence, we have to enclose it in {...}. A normal brace list can
	    " just be appended.
	    let [l:surplusResult, l:isSurplusSequence] = s:Create(a:distinctList[l:sequenceLen :])
	    let l:result = '{' . l:result . '},' . (l:isSurplusSequence ?
	    \   '{' . l:surplusResult . '}' :
	    \   l:surplusResult
	    \)
	endif

	return [l:result, 1]
    else
	return [join(a:distinctList, ','), 0]
    endif
endfunction

function! subs#BraceCreation#Queried( text )
    if ! g:TextTransformContext.isRepeat
	let s:separatorPattern = input('Enter separator pattern: ')
    endif
    return subs#BraceCreation#Do(a:text, s:separatorPattern)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
