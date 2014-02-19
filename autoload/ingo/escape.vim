" ingo/escape.vim: Functions to escape different strings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	15-Jun-2013	file creation

"******************************************************************************
"* PURPOSE:
"   Remove a leading backslash before all {chars} that occur in {string}, and
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
function! ingo#escape#Unescape( string, chars )
    return substitute(a:string, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\ze[' . escape(a:chars, ']^\-') . ']', '', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
