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
"	002	16-Sep-2017	FIX: Need to escape commas in brace items, and
"				literal {..} to avoid that these are interpreted
"				as (separators of a) brace expression.
"				Factor out subs#BraceCreation#FromList().
"				Move wrapping in {...} inside s:Create(), now
"				with an additional a:isWrap argument.
"	001	12-Aug-2017	file creation
let s:save_cpo = &cpo
set cpo&vim

function! subs#BraceCreation#FromSplitString( text, ... )
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
    return subs#BraceCreation#FromList(l:strings)
endfunction
function! subs#BraceCreation#FromList( list )
    let [l:distinctLists, l:commons] = ingo#list#lcs#FindAllCommon(a:list)

    return s:Join(l:distinctLists, l:commons)
endfunction
function! s:Join( distinctLists, commons )
    let l:result = []
    while ! empty(a:distinctLists) || ! empty(a:commons)
	if ! empty(a:distinctLists)
	    let l:distinctList = remove(a:distinctLists, 0)
	    call add(l:result, s:Create(l:distinctList, 1)[0])
	endif

	if ! empty(a:commons)
	    call add(l:result, remove(a:commons, 0))
	endif
    endwhile

    return join(l:result, '')
endfunction
function! s:Create( distinctList, isWrap )
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
	    let [l:surplusResult, l:isSurplusSequence] = s:Create(a:distinctList[l:sequenceLen :], 0)
	    let l:result = s:Brace(l:result) . ',' . s:Brace(l:surplusResult, l:isSurplusSequence)
	endif

	return [s:Brace(l:result), a:isWrap]
    else
	let l:nonEmptyList = filter(copy(a:distinctList), '! empty(v:val)')
	" if len(l:nonEmptyList) == 1
	"     return [s:Wrap('[]', l:nonEmptyList[0]), 0]
	" endif

	return [s:Brace(join(map(a:distinctList, 's:Escape(v:val)'), ','), a:isWrap), 0]
    endif
endfunction
function! s:Wrap( wrap, string, ... )
    return (! a:0 || a:0 && a:1 ? a:wrap[0] . a:string . a:wrap[1] : a:string)
endfunction
function! s:Brace( string, ... )
    return call('s:Wrap', ['{}', a:string] + a:000)
endfunction
function! s:Escape( braceItem )
    return escape(a:braceItem, '{},')
endfunction

function! subs#BraceCreation#Queried( text )
    if ! g:TextTransformContext.isRepeat
	let s:separatorPattern = input('Enter separator pattern: ')
    endif
    return subs#BraceCreation#FromSplitString(a:text, s:separatorPattern)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
