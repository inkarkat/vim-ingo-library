" ingo/query/fromlist.vim: Functions for querying elements from a list.
"
" DEPENDENCIES:
"   - ingo/query/confirm.vim autoload script
"   - ingo/query/get.vim autoload script
"
" Copyright: (C) 2014-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.003	19-Jan-2015	Break listing of query choices into multiple
"				lines when the overall question doesn't fit in a
"				single line.
"   1.023.002	18-Jan-2015	Support ingo#query#fromlist#Query() querying of
"				more than 10 elements by number.
"   1.020.001	03-Jun-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:RenderList( list, defaultIndex, formatString )
    let l:result = []
    for l:i in range(len(a:list))
	call add(l:result,
	\   printf(a:formatString, l:i + 1) .
	\   substitute(a:list[l:i], '&\(.\)', (l:i == a:defaultIndex ? '[\1]' : '(\1)'), '')
	\)
    endfor
    return l:result
endfunction
function! ingo#query#fromlist#Query( what, list, ... )
"******************************************************************************
"* PURPOSE:
"   Query for one entry from a:list; elements can be selected by accelerator key
"   or the number of the element.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Description of what is queried.
"   a:list  List of elements. Accelerators can be preset by prefixing with "&".
"   a:defaultIndex  Default element (which will be chosen via <Enter>); -1 for
"		    no default.
"* RETURN VALUES:
"   Index of the chosen element of a:list, or -1 if the query was aborted.
"******************************************************************************
    let l:defaultIndex = (a:0 ? a:1 : -1)
    let l:confirmList = ingo#query#confirm#AutoAccelerators(copy(a:list), -1)
    let l:accelerators = map(copy(l:confirmList), 'matchstr(v:val, "&\\zs.")')
    let l:list = s:RenderList(l:confirmList, l:defaultIndex, '%d:')

    let l:renderedQuestion = printf('Select %s via [count] or (l)etter: %s ?', a:what, join(l:list, ', '))
    if ingo#compat#strdisplaywidth(l:renderedQuestion) + 3 > &columns
	echohl Question
	echomsg printf('Select %s via [count] or (l)etter:', a:what)
	echohl None
	for l:listItem in s:RenderList(l:confirmList, l:defaultIndex, '%3d: ')
	    echo l:listItem
	endfor
    else
	echohl Question
	echomsg l:renderedQuestion
	echohl None
    endif

    let l:choice = ingo#query#get#Char()
    let l:count = (empty(l:choice) ? -1 : index(l:accelerators, l:choice, 0, 1) + 1)
    if l:count == 0
	let l:count = str2nr(l:choice)
	if len(a:list) > 10 * l:count
	    " Need to query more numbers to be able to address all choices.
	    echon ' ' . l:count

	    while len(a:list) > 10 * l:count
		let l:digit = ingo#query#get#Number(9)
		if l:digit == -1
		    redraw | echo ''
		    return -1
		endif
		let l:count = 10 * l:count + l:digit
	    endwhile
	endif
    endif

    if l:count < 1 || l:count > len(a:list)
	redraw | echo ''
	return -1
    endif
    return l:count - 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
