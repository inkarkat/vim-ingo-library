" ingo/window/iterate.vim: Functions to iterate over windows.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

if exists('*win_execute')
    function! ingo#window#iterate#All( Action, ... ) abort
    "******************************************************************************
    "* PURPOSE:
    "   Execute a:Action in all windows in the current tab page.
    "* ASSUMPTIONS / PRECONDITIONS:
    "   None.
    "* EFFECTS / POSTCONDITIONS:
    "   None.
    "* INPUTS:
    "   a:Action    Either a Funcref (that gets passed all following arguments), or
    "               an Ex command that is :execute'd (ignoring any additional
    "               arguments).
    "* RETURN VALUES:
    "   None.
    "******************************************************************************
	let l:isFuncref = (type(a:Action) == type(function('tr')))

	if winnr('$') == 1
	    if l:isFuncref
		noautocmd keepjumps call call(a:Action, a:000)
	    else
		noautocmd keepjumps execute a:Action
	    endif

	    return
	endif

	let l:command = ((l:isFuncref) ?
	\   'call call(a:Action, a:000)' :
	\   'execute a:Action'
	\)

	for l:winNr in range(1, winnr('$'))
	    call win_execute(win_getid(l:winNr), 'noautocmd keepjumps ' . l:command)
	endfor
    endfunction
else
    function! ingo#window#iterate#All( Action, ... ) abort
	let l:isFuncref = (type(a:Action) == type(function('tr')))

	if winnr('$') == 1
	    if l:isFuncref
		noautocmd keepjumps call call(a:Action, a:000)
	    else
		noautocmd keepjumps execute a:Action
	    endif

	    return
	endif

	" By entering a window, its height is potentially increased from 0 to 1 (the
	" minimum for the current window). To avoid any modification, save the window
	" sizes and restore them after visiting all windows.
	let l:originalWindowLayout = winrestcmd()
	    let l:originalWinNr = winnr()
	    let l:previousWinNr = winnr('#') ? winnr('#') : 1
		if l:isFuncref
		    noautocmd keepjumps windo call call(a:Action, a:000)
		else
		    noautocmd keepjumps windo execute a:Action
		endif
	    noautocmd execute l:previousWinNr . 'wincmd w'
	    noautocmd execute l:originalWinNr . 'wincmd w'
	silent! execute l:originalWindowLayout
    endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
