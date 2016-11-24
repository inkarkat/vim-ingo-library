" ingo/window/locate.vim: Functions to locate a window.
"
" DEPENDENCIES:
"   - ingo/actions.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	25-Nov-2016	file creation

function! s:Match( winVarName, Predicate, winNr, ... )
    let l:tabNr = (a:0 ? a:1 : tabpagenr())
    let l:value = gettabwinvar(l:tabNr, a:winNr, a:winVarName)
    return !! ingo#actions#EvaluateWithValOrFunc(a:Predicate, l:value)
endfunction

function! s:CheckTabPage( tabNr, winVarName, Predicate )
    let [l:currentWinNr, l:lastWinNr] = [tabpagewinnr(a:tabNr), tabpagewinnr(a:tabNr, '$')]
    let l:offset = 1
    while l:currentWinNr - l:offset > 0 || l:currentWinNr + l:offset <= l:lastWinNr
	if s:Match(a:winVarName, a:Predicate, l:currentWinNr - l:offset, a:tabNr)
	    return [a:tabNr, l:currentWinNr - l:offset]
	elseif s:Match(a:winVarName, a:Predicate, l:currentWinNr + l:offset, a:tabNr)
	    return [a:tabNr, l:currentWinNr + l:offset]
	endif
	let l:offset += 1
    endwhile
    return [0, 0]
endfunction

function! ingo#window#locate#NearestByPredicate( isSearchOtherTabPages, winVarName, Predicate )
"******************************************************************************
"* PURPOSE:
"   Locate the window closest to the current one where the window variable a:winVarName makes
"   a:Predicate (passed in as argument or v:val) true.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:winVarName            Name of the window-local variable, like in
"			    |gettabwinvar()|
"   a:Predicate             Either a Funcref or an expression to be eval()ed.
"			    Gets the value of a:winVarName passed, should return
"			    a boolean value.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the found window is on a
"	different tab page
"   [0, winnr] if the window is on the current tab page
"   [0, 0] if a:Predicate did not yield true in any other window
"******************************************************************************
    let l:lastWinNr = winnr('#')
    if l:lastWinNr != 0 && s:Match(a:winVarName, a:Predicate, l:lastWinNr)
	return [tabpagenr(), l:lastWinNr]
    endif

    let l:result = s:CheckTabPage(tabpagenr(), a:winVarName, a:Predicate)
    if l:result != [0, 0] || ! a:isSearchOtherTabPages
	return l:result
    endif


    let [l:currentTabPageNr, l:lastTabPageNr] = [tabpagenr(), tabpagenr('$')]
    let l:offset = 1
    while l:currentTabPageNr - l:offset > 0 || l:currentTabPageNr + l:offset <= l:lastTabPageNr
	let l:result = s:CheckTabPage(l:currentTabPageNr - l:offset, a:winVarName, a:Predicate)
	if l:result != [0, 0] | return l:result | endif

	let l:result = s:CheckTabPage(l:currentTabPageNr + l:offset, a:winVarName, a:Predicate)
	if l:result != [0, 0] | return l:result | endif

	let l:offset += 1
    endwhile

    return [0, 0]
endfunction

" vism: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
