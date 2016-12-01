" ingo/indent.vim: Functions for working with indent.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.001	25-Nov-2016	file creation

function! ingo#indent#RangeSeveralTimes( firstLnum, lastLnum, command, times )
    for l:i in range(a:times)
	silent execute a:firstLnum . ',' . a:lastLnum . a:command
    endfor
endfunction

function! ingo#indent#GetIndent( lnum )
    return matchstr(getline(a:lnum), '^\s*')
endfunction
function! ingo#indent#GetIndentLevel( lnum )
    return indent(a:lnum) / &l:shiftwidth
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
