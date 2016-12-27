" ingo/list/split.vim: Functions for splitting Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	28-Dec-2016	file creation

function! ingo#list#split#ChunksOf( list, n, ... )
"******************************************************************************
"* PURPOSE:
"   Split a:list into a List of Lists of a:n elements.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Clears a:list.
"* INPUTS:
"   a:list  Source list.
"   a:n     Number of elements for each sublist.
"   a:fillValue Optional element that is used to fill the last sublist with if
"		there are not a:n elements left for it. If omitted, the last
"		sublist may have less than a:n elements.
"* RETURN VALUES:
"   [[e1, e2, ... en], [...]]
"******************************************************************************
    let l:result = []
    while ! empty(a:list)
	if len(a:list) >= a:n
	    let l:subList = remove(a:list, 0, a:n - 1)
	else
	    let l:subList = remove(a:list, 0, -1)
	    if a:0
		call extend(l:subList, repeat([a:1], a:n - len(l:subList)))
	    endif
	endif
	call add(l:result, l:subList)
    endwhile
    return l:result
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
