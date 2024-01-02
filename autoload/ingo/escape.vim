" ingo/escape.vim: Functions to escape different strings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2024 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#escape#EscapeExpr( string, expr )
"******************************************************************************
"* PURPOSE:
"   Add a leading backslash before all matches of a:expr that occur in
"   a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    The text to escape.
"   a:expr      Regular expression to escape.
"* RETURN VALUES:
"   Unescaped a:string.
"******************************************************************************
    return substitute(a:string, a:expr, '\\&', 'g')
endfunction

function! ingo#escape#UnescapeExpr( string, expr )
"******************************************************************************
"* PURPOSE:
"   Remove a leading backslash before all matches of a:expr that occur in
"   a:string, and are not itself escaped.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    The text to unescape.
"   a:expr      Regular expression to unescape.
"* RETURN VALUES:
"   Unescaped a:string.
"******************************************************************************
    return substitute(a:string, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\ze' . a:expr, '', 'g')
endfunction

function! ingo#escape#Unescape( string, chars )
"******************************************************************************
"* PURPOSE:
"   Remove a leading backslash before all a:chars that occur in a:string, and
"   are not itself escaped.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    The text to unescape.
"   a:chars     All characters to unescape; probably includes at least the
"		backslash itself.
"* RETURN VALUES:
"   Unescaped a:string.
"******************************************************************************
    return substitute(a:string, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\ze[' . escape(a:chars, ']^\-') . ']', '', 'g')
endfunction

function! ingo#escape#OnlyUnescaped( string, chars )
"******************************************************************************
"* PURPOSE:
"   Escape the characters in a:chars that occur in a:string and are not yet
"   escaped (this is the difference to built-in escape()) with a backslash.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    The text to escape.
"   a:chars     All characters to escape (unless they are already escaped).
"* RETURN VALUES:
"   Escaped a:string.
"******************************************************************************
    return substitute(a:string, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<![' . escape(a:chars, ']^\-') . ']', '\\&', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
