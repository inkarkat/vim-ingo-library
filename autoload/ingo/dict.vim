" ingo/dict.vim: Functions for creating Dictionaries.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	21-Jun-2013	file creation

function! ingo#dict#FromItems( items )
"******************************************************************************
"* PURPOSE:
"   Create a Dictionary object from a list of [key, value] items, as returned by
"   |items()|.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:items List of [key, value] items.
"* RETURN VALUES:
"   A new Dictionary.
"******************************************************************************
    let l:dict = {}
    for [l:key, l:val] in a:items
	let l:dict[l:key] = l:val
    endfor
    return l:dict
endfunction

function! ingo#dict#FromKeys( keys, defaultValue )
"******************************************************************************
"* PURPOSE:
"   Create a Dictionary object from a:keys, all having a:defaultValue.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:keys  The keys of the Dictionary; must not be empty.
"   a:defaultValue  The value for each of the generated keys.
"* RETURN VALUES:
"   A new Dictionary with keys taken from a:keys and a:defaultValue.
"* SEE ALSO:
"   ingo#collections#ToDict() handles empty key values, but uses a hard-coded
"   default value.
"******************************************************************************
    let l:dict = {}
    for l:key in a:keys
	let l:dict[l:key] = a:defaultValue
    endfor
    return l:dict
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
