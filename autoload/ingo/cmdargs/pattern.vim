" ingo/cmdargs/pattern.vim: Functions for parsing of pattern arguments of commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.002	24-Jul-2013	FIX: Use the rules for the /pattern/ separator
"				as stated in :help E146.
"   1.007.001	01-Jun-2013	file creation

function! ingo#cmdargs#pattern#Parse( arguments, ... )
    let l:match = matchlist(a:arguments, '^\([[:alnum:]\\"|]\@![\x00-\xFF]\)\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\1' . (a:0 ? a:1 : '') . '$')
    if empty(l:match)
	return ['/', escape(a:arguments, '/')] + (a:0 ? [''] : [])
    else
	return l:match[1: (a:0 ? 3 : 2)]
    endif
endfunction
function! ingo#cmdargs#pattern#Unescape( parsedArguments )
"******************************************************************************
"* PURPOSE:
"   Unescape the use of the separator from the parsed pattern to yield a plain
"   regular expression, e.g. for use in search().
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:parsedArguments   List with at least two elements: [separator, pattern].
"			separator may be empty; in that case; pattern is
"			returned as-is.
"			You're meant to directly pass the output of
"			ingo#cmdargs#pattern#Parse() in here.
"* RETURN VALUES:
"   If a:parsedArguments contains exactly two arguments: unescaped pattern.
"   Else a List where the first element is the unescaped pattern, and all
"   following elements are taken from the remainder of a:parsedArguments.
"******************************************************************************
    " We don't need the /.../ separation here.
    let l:separator = a:parsedArguments[0]
    let l:unescapedPattern = (empty(l:separator) ?
    \   a:parsedArguments[1] :
    \   substitute(a:parsedArguments[1], '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\V\C' . l:separator, l:separator, 'g')
    \)

    return (len(a:parsedArguments) > 2 ? [l:unescapedPattern] + a:parsedArguments[2:] : l:unescapedPattern)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
