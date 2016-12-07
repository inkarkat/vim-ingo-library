" ingo/cmdargs/register.vim: Functions for parsing a register name.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.002	08-Dec-2016	Add
"				ingo#cmdargs#register#ParsePrependedWritableRegister()
"				alternative to
"				ingo#cmdargs#register#ParseAppendedWritableRegister().
"   1.017.001	10-Mar-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

let s:writableRegisterExpr = '\([-a-zA-Z0-9"*+_/]\)'
function! s:GetDirectSeparator( optionalArguments )
    return (len(a:optionalArguments) > 0 ?
    \   (empty(a:optionalArguments[0]) ?
    \       '\%$\%^' :
    \       a:optionalArguments[0]
    \   ) :
    \   '[[:alnum:][:space:]\\"|]\@![\x00-\xFF]'
    \)
endfunction

function! ingo#cmdargs#register#ParseAppendedWritableRegister( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments into any stuff and a writable register at the end,
"   separated by non-alphanumeric character or whitespace (or the optional
"   a:directSeparator).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:directSeparator   Optional regular expression for the separator (parsed
"			into text) between the text and register (with optional
"			whitespace in between; mandatory whitespace is always an
"			alternative). Defaults to any non-alphanumeric
"			character. If empty: there must be whitespace between
"			text and register.
"* RETURN VALUES:
"   [text, register], or [a:arguments, ''] if no register could be parsed.
"******************************************************************************
    let l:matches = matchlist(a:arguments, '^\(.\{-}\)\%(\%(\%(' . s:GetDirectSeparator(a:000) . '\)\@<=\s*\|\s\+\)' . s:writableRegisterExpr . '\)$')
    return (empty(l:matches) ? [a:arguments, ''] : l:matches[1:2])
endfunction

function! ingo#cmdargs#register#ParsePrependedWritableRegister( arguments, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:arguments into a writable register at the beginning, and any
"   following stuff, separated by non-alphanumeric character or whitespace (or
"   the optional a:directSeparator).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:arguments Command arguments to parse.
"   a:directSeparator   Optional regular expression for the separator (parsed
"			into text) between the text and register (with optional
"			whitespace in between; mandatory whitespace is always an
"			alternative). Defaults to any non-alphanumeric
"			character. If empty: there must be whitespace between
"			text and register.
"* RETURN VALUES:
"   [register, text], or ['', a:arguments] if no register could be parsed.
"******************************************************************************
    let l:matches = matchlist(a:arguments, '^' . s:writableRegisterExpr . '\%(\%(\s*' . s:GetDirectSeparator(a:000) . '\)\@=\|\s\+\)\(.*\)$')
    return (empty(l:matches) ? ['', a:arguments] : l:matches[1:2])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
