" ingo/undo.vim: Functions for undo and dealing with changes.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.001	25-Apr-2014	file creation

function! ingo#undo#GetChangeNumber()
"******************************************************************************
"* PURPOSE:
"   Get the current change number, for use e.g. with :undo {N}.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   If undotree() is not available, makes an additional no-op change.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Change number, or -1.
"******************************************************************************
    if exists('*undotree')
	return undotree().seq_cur
    else
	" Cannot directly get the current undo sequence number from :undolist;
	" must create a new undo point, and later potentially undo beyond that.
	try
	    call setline('$', getline('$'))
	catch /^Vim\%((\a\+)\)\=:/
	    return -1
	endtry
	redir => l:undolistOutput
	    silent! undolist
	redir END
	let l:undoChangeNumber = str2nr(split(l:undolistOutput, "\n")[-1])
	return (l:undoChangeNumber == 0 ? -1 : l:undoChangeNumber)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
