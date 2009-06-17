" surroundings.vim: Generic functions to surround text with something. 
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2008 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	24-Sep-2008	file creation from ingotextobjects.vim

"- functions ------------------------------------------------------------------
function! surroundings#SurroundWith( selectionType, textBefore, textAfter )
    if a:selectionType ==# 'z'
	" This special selection type assumes that the surrounded text has
	" already been captured in register z and replaced with a single
	" character. It is necessary for the "surround with one typed character"
	" mapping, so that the visual selection has already been captured and
	" the placeholder '$' is already shown to the user when the character is
	" queried. 

	" Set paste type to characterwise; otherwise, linewise selections would
	" be pasted _below_ the surrounded characters. 
	call setreg('z', '', 'av')
	execute 'normal! s' . a:textBefore . "\<C-R>\<C-O>z" . a:textAfter . "\<Esc>"
    elseif a:selectionType ==# 'v'
	let l:save_register = @z
	normal! gv"zs$

	" Set paste type to characterwise; otherwise, linewise selections would
	" be pasted _below_ the surrounded characters. 
	call setreg('z', '', 'av')
	execute 'normal! s' . a:textBefore . "\<C-R>\<C-O>z" . a:textAfter . "\<Esc>"

	let @z = l:save_register
    else
	if a:selectionType ==# 'w'
	    let l:backmotion = 'b'
	    let l:backendmotion = 'e'
	elseif a:selectionType ==# 'W'
	    let l:backmotion = 'B'
	    let l:backendmotion = 'E'
	else
	    throw "This selection type has not been implemented."
	endif
	let l:textBeforeCharacterCnt = strlen(substitute(a:textBefore, ".", "x", "g"))
	let l:restoreOriginalPosition = '`z' . l:textBeforeCharacterCnt . 'l'
	execute 'normal! mzw' . l:backmotion . "i". a:textBefore . "\<Esc>" . l:backendmotion . "a" . a:textAfter . "\<Esc>" . l:restoreOriginalPosition
    endif
endfunction

function! surroundings#SurroundWithSingleChar( selectionType, char )
    call surroundings#SurroundWith( a:selectionType, a:char, a:char )
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
