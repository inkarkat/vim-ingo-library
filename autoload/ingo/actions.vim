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
"   1.014.006	05-Nov-2013	Add ingo#actions#ValueOrFunc().
"   1.011.005	01-Aug-2013	Add ingo#actions#EvaluateWithValOrFunc().
"   1.010.004	04-Jul-2013	Add ingo#actions#EvaluateWithVal().
"   1.010.003	03-Jul-2013	Move into ingo-library.
"				Allow to specify Funcref arguments.
"	002	17-Jan-2013	Add ingoactions#EvaluateOrFunc(), used by
"				autoload/ErrorFix.vim.
"	001	23-Oct-2012	file creation

function! ingo#actions#ValueOrFunc( Action, ... )
    if type(a:Action) == type(function('tr'))
	return call(a:Action, (a:0 ? a:1 : []))
    else
	return a:Action
    endif
endfunction
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
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Action; a Funcref is passed all arguments, else it is eval()ed.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be eval()ed.
"   a:arguments Value(s) to be passed to the a:Action Funcref (but not the
"		expression; use ingo#actions#EvaluateWithValOrFunc() for that).
"* RETURN VALUES:
"   Result of evaluating a:Action.
"******************************************************************************
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
function! ingo#actions#EvaluateWithValOrFunc( Action, ... )
"******************************************************************************
"* PURPOSE:
"   Evaluate a:Action; a Funcref is passed all arguments, else each occurrence
"   of "v:val" is replaced with the single argument / a List of the passed
"   arguments.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:Action    Either a Funcref or an expression to be eval()ed.
"   a:arguments Value(s) to be passed to the a:Action Funcref or used for
"		occurrences of "v:val" inside the a:Action expression.
"* RETURN VALUES:
"   Result of evaluating a:Action.
"******************************************************************************
    if type(a:Action) == type(function('tr'))
	return call(a:Action, (a:0 ? a:000 : []))
    else
	let l:val = (a:0 == 1 ? a:1 : a:000)
	return get(map([l:val], a:Action), 0, '')
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
