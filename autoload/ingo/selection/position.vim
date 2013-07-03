" ingo/selection/position.vim: Functions for getting the positions of the selection.
"
" DEPENDENCIES:
"   - ingo/cursor/move.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.010.001	04-Jul-2013	file creation

function! ingo#selection#position#Get()
    let l:startPos = getpos("'<")
    let l:endPos = getpos("'>")
    if &selection ==# 'exclusive'
	normal! g`>
	call ingo#cursor#move#Left()
	let l:endPos = getpos('.')
	normal! g`<
    endif

    return [l:startPos, l:endPos]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
