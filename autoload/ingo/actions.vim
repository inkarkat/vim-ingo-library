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
"   1.010.004	04-Jul-2013	Add ingo#actions#EvaluateWithVal().
"   1.010.003	03-Jul-2013	Move into ingo-library.
"				Allow to specify Funcref arguments.
"	002	17-Jan-2013	Add ingoactions#EvaluateOrFunc(), used by
"				autoload/ErrorFix.vim.
"	001	23-Oct-2012	file creation

function! ingo#actions#NormalOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, (a:0 ? a:1 : []))
    else
	execute 'normal!' a:Action
	return ''
    endif
endfunction
function! ingo#actions#ExecuteOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, (a:0 ? a:1 : []))
    else
	execute a:Action
	return ''
    endif
endfunction
function! ingo#actions#EvaluateOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, (a:0 ? a:1 : []))
    else
	return eval(a:Action)
    endif
endfunction

function! ingo#actions#EvaluateWithVal( expression, val )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:expression; each occurrence of "v:val" is replaced with a:val,
"   just like in |map()|.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expression    An expression to be eval()ed.
"   a:val           Value to be used for occurrences of "v:val" inside
"		    a:expression.
"* RETURN VALUES:
"   Result of evaluating a:expression.
"******************************************************************************
    return get(map([a:val], a:expression), 0, '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
