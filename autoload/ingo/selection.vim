" ingo/selection.vim: Functions for accessing the visually selected text.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.006.001	24-May-2013	file creation from ingointegration.vim.

function! ingo#selection#Get()
"******************************************************************************
"* PURPOSE:
"   Retrieve the contents of the current visual selection without clobbering any
"   register.
"* ASSUMPTIONS / PRECONDITIONS:
"   Visual selection is / has been made.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Text of visual selection.
"******************************************************************************
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
	let l:save_reg = getreg('"')
	let l:save_regmode = getregtype('"')
	    execute 'silent! normal! gvy'
	    let l:selection = @"
	call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    return l:selection
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
