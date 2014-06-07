" ingo/join.vim: Functions for joining lines in the buffer.
"
" DEPENDENCIES:
"   - ingo/folds.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.001	08-Jun-2014	file creation from ingocommands.vim

function! ingo#join#Lines( lnum, isKeepSpace, separator )
    if a:isKeepSpace
	let l:lineLen = len(getline(a:lnum))
	execute a:lnum . 'join!'
	if ! empty(a:separator)
	    if len(getline(a:lnum)) == l:lineLen
		" The next line was completely empty.
		execute 'normal! A' . a:separator . "\<Esc>"
	    else
		call cursor(a:lnum, l:lineLen + 1)
		execute 'normal! i' . a:separator . "\<Esc>"
	    endif
	endif
    else
	execute a:lnum
	normal! J
	if ! empty(a:separator)
	    execute 'normal! ciw' . a:separator . "\<Esc>"
	endif
    endif
endfunction

function! ingo#join#FoldedLines( isKeepSpace, startLnum, endLnum, separator )
    let l:folds = ingo#folds#GetClosedFolds(a:startLnum, a:endLnum)
    if empty(l:folds)
	return [0, 0]
    endif

    let l:joinCnt = 0
    let l:save_foldenable = &foldenable
    set nofoldenable
    try
	for [l:foldStartLnum, l:foldEndLnum] in reverse(l:folds)
	    let l:cnt = l:foldEndLnum - l:foldStartLnum
	    for l:i in range(l:cnt)
		call ingo#join#Lines(l:foldStartLnum, a:isKeepSpace, a:separator)
	    endfor
	    let l:joinCnt += l:cnt
	endfor
    finally
	let &foldenable = l:save_foldenable
    endtry
    return [len(l:folds), l:joinCnt]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
