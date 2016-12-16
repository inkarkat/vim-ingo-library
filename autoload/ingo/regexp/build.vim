" ingo/regexp/build.vim: Functions to build regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	17-Dec-2016	file creation

function! ingo#regexp#build#Prepend( target, fragment )
"******************************************************************************
"* PURPOSE:
"   Add a:fragment at the beginning of a:target, considering the anchor ^.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:target    Regular expression to manipulate.
"   a:fragment  Regular expression fragment to insert.
"* RETURN VALUES:
"   New regexp.
"******************************************************************************
    return substitute(a:target, '^\%(\\%\?(\)*^\?', '&' . escape(a:fragment, '\&'), '')
endfunction

function! ingo#regexp#build#Append( target, fragment )
"******************************************************************************
"* PURPOSE:
"   Add a:fragment at the end of a:target, considering the anchor $.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:target    Regular expression to manipulate.
"   a:fragment  Regular expression fragment to insert.
"* RETURN VALUES:
"   New regexp.
"******************************************************************************
    return substitute(a:target, '$\?\%(\\)\)*$', escape(a:fragment, '\&') . '&', '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
