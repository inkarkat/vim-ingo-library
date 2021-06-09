" ingo/buffers.vim: Functions to manipulate buffers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#buffers#Delete( buffersToDelete, isForce ) abort
"******************************************************************************
"* PURPOSE:
"   Delete (:bdelete) all buffers in a:buffersToDelete, and collect any
"   encountered errors.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   - Buffers in a:buffersToDelete are deleted from the buffer list.
"* INPUTS:
"   a:buffersToDelete   List of buffer numbers.
"   a:isForce           Force flag; uses :bdelete! if true.
"* RETURN VALUES:
"   1 if complete success, 0 if error(s) / exception(s) occurred. An error
"   message is then available from ingo#err#Get().
"******************************************************************************
    call ingo#err#Clear()
    let l:errors = []
    for l:bufNr in a:buffersToDelete
	try
	    execute l:bufNr . 'bdelete' . (a:isForce ? '!' : '')
	catch /^Vim\%((\a\+)\)\=:/
	    call add(l:errors, printf('%s: %s', ingo#buffer#NameOrDefault(bufname(l:bufNr)), ingo#msg#MsgFromVimException()))
	endtry
    endfor

    if empty(l:errors)
	let l:isSuccess = 1
    else
	call ingo#err#Set(join(l:errors))
	let l:isSuccess = 0
    endif

    return l:isSuccess
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
