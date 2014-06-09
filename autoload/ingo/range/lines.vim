" ingo/range/Lines.vim: Functions for retrieving line numbers of ranges.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.001	10-Jun-2014	file creation from
"				autoload/PatternsOnText/Ranges.vim

function! s:RecordLine( records, startLnum, endLnum )
    let l:lnum = line('.')
    if l:lnum < a:startLnum || l:lnum > a:endLnum
	return
    endif

    let a:records[l:lnum] = 1
endfunction
function! ingo#range#lines#Get( startLnum, endLnum, range )
    let l:recordedLines = {}

    if a:range =~# '^[/?]'
	" For patterns, we need :global to find _all_ (not just the first)
	" matching ranges.
	execute printf('silent! %d,%dglobal %s call <SID>RecordLine(l:recordedLines, %d, %d)',
	\  a:startLnum, a:endLnum,
	\  a:range,
	\  a:startLnum, a:endLnum
	\)
	let l:didClobberSearchHistory = 1
    else
	" For line number, marks, etc., we can just record them (limited to
	" those that fall into the command's range).
	execute printf('silent! %s call <SID>RecordLine(l:recordedLines, %d, %d)',
	\  a:range,
	\  a:startLnum, a:endLnum
	\)
	let l:didClobberSearchHistory = 0
    endif

    return [l:recordedLines, l:didClobberSearchHistory]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
