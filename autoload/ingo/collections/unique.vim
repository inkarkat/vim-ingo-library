" ingo/collections/unique.vim: Functions to create and operate on unique collections.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	25-Jun-2013	file creation

function! ingo#collections#unique#MakeUnique( memory, expr )
"******************************************************************************
"* PURPOSE:
"   Based on the a:memory lookup, create a unique String from a:expr by
"   appending a running counter to it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Adds the unique returned result to a:memory.
"* INPUTS:
"   a:memory    Dictionary holding the existing values as keys.
"   a:expr      String that is made unique with regards to a:memory and
"		returned.
"* RETURN VALUES:
"   a:expr (when it's not yet contained in the a:memory), or a unique version of
"   it.
"******************************************************************************
    let l:result = a:expr
    let l:counter = 0
    while has_key(a:memory, l:result)
	let l:counter += 1
	let l:result = printf('%s%s(%d)', a:expr, (empty(a:expr) ? '' : ' '), l:counter)
    endwhile

    let a:memory[l:result] = 1
    return l:result
endfunction

function! ingo#collections#unique#ExtendWithNew( expr1, expr2, ... )
"******************************************************************************
"* PURPOSE:
"   Append all items from a:expr2 that are not yet contained in a:expr1 to it.
"   If a:expr3 is given insert the items of a:expr2 before item a:expr3 in
"   a:expr1. When a:expr3 is zero insert before the first item.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"* RETURN VALUES:
"   Returns the modified a:expr1.
"******************************************************************************
    let l:newItems = filter(copy(a:expr2), 'index(a:expr1, v:val) == -1')
    return call('extend', [a:expr1, l:newItems] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
