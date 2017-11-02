" ingo/plugin/cmdcomplete.vim: Functions to build simple command completions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:completeFuncCnt = 0
function! ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc( argumentList, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   from a static list of possible arguments.
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"   \   ['foo', 'fox', 'bar'], 'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"	\   ['foo', 'fox', 'bar']) . 'Foo ...'
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:argumentList  List of possible arguments.
"   a:funcName      Optional name for the complete function; when not specified,
"		    a unique name is generated.
"* RETURN VALUES:
"   Name of the defined complete function.
"******************************************************************************
    if a:0
	let l:funcName = a:1
    else
	let s:completeFuncCnt += 1
	let l:funcName = printf('CompleteFunc%d', s:completeFuncCnt)
    endif

    execute
    \   printf('function! %s( ArgLead, CmdLine, CursorPos )', l:funcName) . "\n" .
    \   printf('    return filter(%s, ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'')', string(a:argumentList)) . "\n" .
    \          'endfunction'

    return l:funcName
endfunction

function! ingo#plugin#cmdcomplete#MakeListExprCompleteFunc( argumentExpr, ... )
"******************************************************************************
"* PURPOSE:
"   Define a complete function for :command -complete=customlist that completes
"   from a (dynamically invoked) expression.
"* USAGE:
"   call ingo#plugin#cmdcomplete#MakeListExprCompleteFunc(
"   \   'map(copy(g:values), "v:val[0:3]")', 'FooCompleteFunc')
"   command! -complete=customlist,FooCompleteFunc Foo ...
"	or alternatively
"   execute 'command! -complete=customlist,' .
"	ingo#plugin#cmdcomplete#MakeFixedListCompleteFunc(
"	\   'map(copy(g:values), "v:val[0:3]")') ...
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines function.
"* INPUTS:
"   a:argumentExpr  Expression that returns a List of (currently) possible
"		    arguments when evaluated.
"   a:funcName      Optional name for the complete function; when not specified,
"		    a unique name is generated.
"* RETURN VALUES:
"   Name of the defined complete function.
"******************************************************************************
    if a:0
	let l:funcName = a:1
    else
	let s:completeFuncCnt += 1
	let l:funcName = printf('CompleteFunc%d', s:completeFuncCnt)
    endif

    execute
    \   printf('function! %s( ArgLead, CmdLine, CursorPos )', l:funcName) . "\n" .
    \   printf('    return filter(%s, ''v:val =~ "\\V\\^" . escape(a:ArgLead, "\\")'')', a:argumentExpr) . "\n" .
    \          'endfunction'

    return l:funcName
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
