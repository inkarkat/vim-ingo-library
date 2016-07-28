" ingo/actions/iterations.vim: Repeated action execution over several targets.
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
"   1.025.001	29-Jul-2016	file creation

function! ingo#actions#iterations#WinDo( alreadyVisistedBuffers, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Action on each window in the current tab page, unless the buffer is
"   in a:alreadyVisistedBuffers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:alreadyVisistedBuffers    Dictionary with already visited buffer numbers
"				as keys. Will be added to, and the same buffers
"				in other windows will be skipped. Pass 0 to
"				visit _all_ windows, regardless of the buffers
"				they display.
"   a:Action                    Either a Funcref or Ex commands to be executed
"				in each window.
"   ...                         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:originalWinNr = winnr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1

    " By entering a window, its height is potentially increased from 0 to 1 (the
    " minimum for the current window). To avoid any modification, save the window
    " sizes and restore them after visiting all windows.
    let l:originalWindowLayout = winrestcmd()
    let l:didSwitchWindows = 0

    try
	for l:winNr in range(1, winnr('$'))
	    let l:bufNr = winbufnr(l:winNr)
	    if a:alreadyVisistedBuffers is# 0 || ! has_key(a:alreadyVisistedBuffers, l:bufNr)
		if l:winNr != winnr()
		    execute 'noautocmd' l:winNr . 'wincmd w'
		    let l:didSwitchWindows = 1
		endif
		if type(a:alreadyVisistedBuffers) == type({}) | let a:alreadyVisistedBuffers[bufnr('')] = 1 | endif

		call call(function('ingo#actions#ExecuteOrFunc'), a:000)
	    endif
	endfor
    finally
	if l:didSwitchWindows
	    noautocmd execute l:previousWinNr . 'wincmd w'
	    noautocmd execute l:originalWinNr . 'wincmd w'
	    silent! execute l:originalWindowLayout
	endif
    endtry
endfunction
function! ingo#actions#iterations#TabWinDo( alreadyVisistedTabPages, alreadyVisistedBuffers, ... )
"******************************************************************************
"* PURPOSE:
"   Invoke a:Action on each window in each tab page, unless the buffer is in
"   a:alreadyVisistedBuffers.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:alreadyVisistedTabPages   Dictionary with already visited tabpage numbers
"				as keys. Will be added to, those tab pages will
"				be skipped. Pass empty Dictionary to visit _all_
"				tab pages.
"   a:alreadyVisistedBuffers    Dictionary with already visited buffer numbers
"				as keys. Will be added to, and the same buffers
"				in other windows / tab pages will be skipped.
"				Pass 0 to visit _all_ windows and tab pages,
"				regardless of the buffers they display.
"   a:Action                    Either a Funcref or Ex commands to be executed
"				in each window.
"   ...                         Arguments passed to an a:Action Funcref.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let l:originalTabNr = tabpagenr()
    let l:didSwitchTabs = 0
    try
	for l:tabNr in range(1, tabpagenr('$'))
	    if ! has_key(a:alreadyVisistedTabPages, l:tabNr)
		let a:alreadyVisistedTabPages[l:tabNr] = 1
		if ! empty(a:alreadyVisistedBuffers) && ingo#collections#differences#ContainsLoosely(keys(a:alreadyVisistedBuffers), tabpagebuflist(l:tabNr))
		    " All buffers of that tab page have already been visited; no
		    " need to go there.
		    continue
		endif

		if l:tabNr != tabpagenr()
		    execute 'noautocmd' l:tabNr . 'tabnext'
		    let l:didSwitchTabs = 1
		endif

		let l:originalWinNr = winnr()
		let l:previousWinNr = winnr('#') ? winnr('#') : 1
		" By entering a window, its height is potentially increased from 0 to 1 (the
		" minimum for the current window). To avoid any modification, save the window
		" sizes and restore them after visiting all windows.
		let l:originalWindowLayout = winrestcmd()
		let l:didSwitchWindows = 0

		try
		    for l:winNr in range(1, winnr('$'))
			let l:bufNr = winbufnr(l:winNr)
			if a:alreadyVisistedBuffers is# 0 || ! has_key(a:alreadyVisistedBuffers, l:bufNr)
			    execute 'noautocmd' l:winNr . 'wincmd w'

			    let l:didSwitchWindows = 1
			    if type(a:alreadyVisistedBuffers) == type({}) | let a:alreadyVisistedBuffers[bufnr('')] = 1 | endif

			    call call(function('ingo#actions#ExecuteOrFunc'), a:000)
			endif
		    endfor
		finally
		    if l:didSwitchWindows
			noautocmd execute l:previousWinNr . 'wincmd w'
			noautocmd execute l:originalWinNr . 'wincmd w'
			silent! execute l:originalWindowLayout
		    endif
		endtry
	    endif
	endfor
    finally
	if l:didSwitchTabs
	    noautocmd execute l:originalTabNr . 'tabnext'
	endif
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
