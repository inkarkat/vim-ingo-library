" ingo/actions.vim: Functions for flexible action execution.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.010.003	03-Jul-2013	Move into ingo-library.
"	002	17-Jan-2013	Add ingoactions#EvaluateOrFunc(), used by
"				autoload/ErrorFix.vim.
"	001	23-Oct-2012	file creation

function! ingo#actions#NormalOrFunc( Action )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, [])
    else
	execute 'normal!' a:Action
	return ''
    endif
endfunction
function! ingo#actions#ExecuteOrFunc( Action )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, [])
    else
	execute a:Action
	return ''
    endif
endfunction
function! ingo#actions#EvaluateOrFunc( Action )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, [])
    else
	return eval(a:Action)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
