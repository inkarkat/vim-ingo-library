" ingo/buffer/locate.vim: Functions to locate a buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	18-Nov-2016	file creation

function! ingo#buffer#locate#NearestWindow( isSearchOtherTabPages, bufNr )
"******************************************************************************
"* PURPOSE:
"   Locate the window closest to the current one that contains a:bufNr. Like
"   bufwinnr() with different precedences, and optionally looking into other tab
"   pages.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isSearchOtherTabPages Flag whether windows in other tab pages should also
"			    be considered.
"   a:bufNr                 Buffer number of the target buffer.
"* RETURN VALUES:
"   [tabpagenr, winnr] if a:isSearchOtherTabPages and the buffer is on a
"	different tab page
"   [0, winnr] if the buffer is on the current tab page
"   [0, 0] if a:bufNr is not found in other windows
"******************************************************************************
    let l:lastWinNr = winnr('#')
    if l:lastWinNr != 0 && winbufnr(l:lastWinNr) == a:bufNr
	return [tabpagenr(), l:lastWinNr]
    endif

    let [l:currentWinNr, l:lastWinNr] = [winnr(), winnr('$')]
    let l:offset = 1
    while l:currentWinNr - l:offset > 0 || l:currentWinNr + l:offset <= l:lastWinNr
	if winbufnr(l:currentWinNr - l:offset) == a:bufNr
	    return [tabpagenr(), l:currentWinNr - l:offset]
	elseif winbufnr(l:currentWinNr + l:offset) == a:bufNr
	    return [tabpagenr(), l:currentWinNr + l:offset]
	endif
	let l:offset += 1
    endwhile

    if ! a:isSearchOtherTabPages
	return [0, 0]
    endif

    let [l:currentTabPageNr, l:lastTabPageNr] = [tabpagenr(), tabpagenr('$')]
    let l:offset = 1
    while l:currentTabPageNr - l:offset > 0 || l:currentTabPageNr + l:offset <= l:lastTabPageNr
	let l:winNr = s:FindBufferOnTabPage(l:currentTabPageNr - l:offset, a:bufNr)
	if l:winNr != 0
	    return [l:currentTabPageNr - l:offset, l:winNr]
	endif
	let l:winNr = s:FindBufferOnTabPage(l:currentTabPageNr + l:offset, a:bufNr)
	if l:winNr != 0
	    return [l:currentTabPageNr + l:offset, l:winNr]
	endif
	let l:offset += 1
    endwhile

    return [0, 0]
endfunction
function! s:FindBufferOnTabPage( tabPageNr, bufNr )
    let l:bufferNumbers = tabpagebuflist(a:tabPageNr)
    for l:i in range(len(l:bufferNumbers))
	if l:bufferNumbers[l:i] == a:bufNr
	    return l:i + 1
	endif
    endfor
    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
