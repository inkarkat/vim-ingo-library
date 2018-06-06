" ingo/list/pattern.vim: Functions for applying a regular expression to List items.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#list#pattern#AllItemsMatch( list, expr )
"******************************************************************************
"* PURPOSE:
"   Test whether each item of the list matches the regular expression.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  A list.
"   a:expr  Regular expression.
"* RETURN VALUES:
"   1 if all items of a:list match a:expr; else 0.
"******************************************************************************
    return empty(filter(copy(a:list), 'v:val !~# a:expr'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
