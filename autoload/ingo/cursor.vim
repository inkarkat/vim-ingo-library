" ingo/cursor.vim: Functions for the cursor position.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.001	11-Dec-2013	file creation

function! ingo#cursor#Set( lnum, virtcol )
"******************************************************************************
"* PURPOSE:
"   Set the cursor position to a virtual column, not the byte count like
"   cursor() does.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Re-positions the cursor.
"* INPUTS:
"   a:lnum  Line number; if {lnum} is zero, the cursor will stay in the current
"	    line.
"   a:virtcol   Screen column; if no such column is available, will put the
"		cursor on the last character in the line.
"* RETURN VALUES:
"   1 if the desired virtual column has been reached; 0 otherwise.
"******************************************************************************
    if a:lnum != 0
	call cursor(a:lnum, 0)
    endif
    execute 'normal!' a:virtcol . '|'
    return (virtcol('.') == a:virtcol)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
