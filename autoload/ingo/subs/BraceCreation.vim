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
	    call add(l:result, s:Translate(l:distinctList))
	endif

	if ! empty(a:commons)
	    call add(l:result, remove(a:commons, 0))
	endif
    endwhile

    return join(l:result, '')
endfunction
function! s:Translate( distinctList )
    if empty(a:distinctList)
	return ''
    endif

    let [l:sequenceLen, l:stride] = ingo#list#sequence#FindNumerical(a:distinctList)
    if l:sequenceLen <= 2 || ! ingo#list#Matches(a:distinctList[0 : l:sequenceLen - 1], '^\d\+$')
	let [l:sequenceLen, l:stride] = ingo#list#sequence#FindCharacter(a:distinctList)
    endif
    if l:sequenceLen > 2
	let l:result = a:distinctList[0] . '..' . a:distinctList[l:sequenceLen - 1] .
	\   (ingo#compat#abs(l:stride) == 1 ? '' : '..' . l:stride)

	if l:sequenceLen < len(a:distinctList)
	    let l:result = '{' . l:result . '},' . join(a:distinctList[l:sequenceLen :], ',')
	endif
    else
	let l:result = join(a:distinctList, ',')
    endif

    return '{' . l:result . '}'
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
