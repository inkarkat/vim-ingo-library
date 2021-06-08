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
    "   a:Action    Either a Funcref or an expression to be :execute'd.
    "   a:arguments Value(s) to be passed to the a:Action Funcref or used for
    "               occurrences of "v:val" inside the a:Action expression. The
    "               v:val is inserted literally (as a Number, String, List,
    "               Dict)!
    "* RETURN VALUES:
    "   None.
    "******************************************************************************
	let l:isFuncref = (type(a:Action) == type(function('tr')))

	if ! l:isFuncref
	    let l:val = (a:0 == 1 ? a:1 : a:000)
	    if type(l:val) == type([]) || type(l:val) == type({})
		" Avoid "E730: using List as a String" in the substitution.
		let l:val = string(l:val)
	    endif

	    let l:command = substitute(a:Action, '\C' . ingo#actions#GetValExpr(), l:val, 'g')
	endif

	if winnr('$') == 1
	    if l:isFuncref
		call call(a:Action, a:000)
	    else
		execute l:command
	    endif

	    return
	endif

	let l:command = ((l:isFuncref) ?
	\   'call call(a:Action, a:000)' :
	\   'execute ' . string(l:command)
	\)

	for l:winNr in range(1, winnr('$'))
	    call win_execute(win_getid(l:winNr), l:command)
	endfor
    endfunction
else
    function! ingo#window#iterate#All( Action, ... ) abort
	let l:isFuncref = (type(a:Action) == type(function('tr')))

	if ! l:isFuncref
	    let l:val = (a:0 == 1 ? a:1 : a:000)
	    if type(l:val) == type([]) || type(l:val) == type({})
		" Avoid "E730: using List as a String" in the substitution.
		let l:val = string(l:val)
	    endif

	    let l:command = substitute(a:Action, '\C' . ingo#actions#GetValExpr(), l:val, 'g')
	endif

	if winnr('$') == 1
	    if l:isFuncref
		call call(a:Action, a:000)
	    else
		execute l:command
	    endif

	    return
	endif

	" By entering a window, its height is potentially increased from 0 to 1 (the
	" minimum for the current window). To avoid any modification, save the window
	" sizes and restore them after visiting all windows.
	    let l:save_eventignore = &eventignore
		let l:originalWindowLayout = winrestcmd()
		    let l:originalWinNr = winnr()
		    let l:previousWinNr = winnr('#') ? winnr('#') : 1
	set eventignore+=BufEnter,BufLeave,WinEnter,WinLeave,CmdwinEnter,CmdwinLeave
	try
	    if l:isFuncref
		keepjumps windo call call(a:Action, a:000)
	    else
		keepjumps windo execute l:command
	    endif
	finally
		    noautocmd execute l:previousWinNr . 'wincmd w'
		    noautocmd execute l:originalWinNr . 'wincmd w'
		silent! execute l:originalWindowLayout
	    let &eventignore = l:save_eventignore
	endtry
    endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
