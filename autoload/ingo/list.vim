" ingo/list.vim: Functions to operate on Lists.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.003	10-Oct-2016	Add ingo#list#Join().
"   1.024.002	16-Mar-2015	Add ingo#list#Zip() and ingo#list#ZipLongest().
"   1.014.001	15-Oct-2013	file creation

function! ingo#list#Make( val, ... )
"******************************************************************************
"* PURPOSE:
"   Ensure that the passed a:val is a List; if not, wrap it in one.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:val   Arbitrary value of arbitrary type.
"   a:isCopyOriginalList    Optional flag; when set, an original a:val List is
"			    copied before returning.
"* RETURN VALUES:
"   List; either the original one or a new one containing a:val.
"******************************************************************************
    return (type(a:val) == type([]) ? (a:0 && a:1 ? copy(a:val) : a:val) : [a:val])
endfunction

function! ingo#list#AddOrExtend( list, val, ... )
"******************************************************************************
"* PURPOSE:
"   Add a:val as element(s) to a:list. Extends a List, adds other types.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list  List to be extended.
"   a:val   Arbitrary value of arbitrary type.
"   a:idx   Optional index before where in a:list to insert. Default to
"	    appending.
"* RETURN VALUES:
"   Returns the resulting a:list.
"******************************************************************************
    if type(a:val) == type([])
	if a:0
	    call extend(a:list, a:val, a:1)
	else
	    call extend(a:list, a:val)
	endif
    else
	if a:0
	    call insert(a:list, a:val, a:1)
	else
	    call add(a:list, a:val)
	endif
    endif
    return a:list
endfunction

function! ingo#list#Zip( ... )
"******************************************************************************
"* PURPOSE:
"   From several Lists, create a combined List. The first item is a List of all
"   first items of the original Lists, the second a List of all second items,
"   and so on, until one List is exhausted. Surplus items in other Lists are
"   omitted.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1, a:list2
"* RETURN VALUES:
"   List of Lists, each containing a certain index item of all source Lists.
"******************************************************************************
    let l:result = []
    for l:i in range(min(map(copy(a:000), 'len(v:val)')))
	call add(l:result, map(copy(a:000), 'v:val[l:i]'))
    endfor
    return l:result
endfunction

function! ingo#list#ZipLongest( defaultValue, ... )
"******************************************************************************
"* PURPOSE:
"   From several Lists, create a combined List. The first item is a List of all
"   first items of the original Lists, the second a List of all second items,
"   and so on, until all Lists are exhausted. Missing items in shorter Lists are
"   replaced by a:defaultValue.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1, a:list2
"* RETURN VALUES:
"   List of Lists, each containing a certain index item of all source Lists.
"******************************************************************************
    let l:result = []
    for l:i in range(max(map(copy(a:000), 'len(v:val)')))
	call add(l:result, map(copy(a:000), 'get(v:val, l:i, a:defaultValue)'))
    endfor
    return l:result
endfunction

function! ingo#list#Join( ... )
"******************************************************************************
"* PURPOSE:
"   From several Lists, create a combined List, starting with all first items,
"   then all second items, and so on.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:list1, a:list2
"* RETURN VALUES:
"   List of joined source Lists, from low to high indices.
"******************************************************************************
    let l:result = []
    let l:i = 0
    let l:isAdded = 1
    while l:isAdded
	let l:isAdded = 0
	for l:j in range(a:0)
	    if l:i < len(a:000[l:j])
		call add(l:result, a:000[l:j][l:i])
		let l:isAdded = 1
	    endif
	endfor
	let l:i += 1
    endwhile
    return l:result
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
