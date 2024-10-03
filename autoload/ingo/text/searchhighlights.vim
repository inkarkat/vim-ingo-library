" ingo/text/searchhighlights.vim: Functions to obtain search highlights.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#text#searchhighlights#GetForLine( lnum, column, pattern )
    let l:save_cursor = ingo#compat#getcurpos()
    " Start at the beginning of the passed line.
    call cursor(a:lnum, 1)

    let l:highlights = []
    let l:startSearchFlags = 'c'
    while 1
	let [l:lnum, l:startCol] = searchpos(a:pattern, l:startSearchFlags, a:lnum)
	let [l:lnum, l:endCol] = searchpos(a:pattern, 'cen', a:lnum)
	let l:startSearchFlags = ''
	if l:startCol == 0
	    " No more matches in this line.
	    break
	endif
	if l:endCol == 0
	    " The end of the match is not in this line any more.
	    let l:endCol = col('$')
	endif

	call add(l:highlights, [ l:startCol, l:endCol, (l:startCol == a:column ? 'IncSearch' : 'Search') ])
    endwhile

    " Restore the cursor position.
    call setpos('.', l:save_cursor)

    return l:highlights
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
