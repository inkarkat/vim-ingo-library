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
" Copyright: (C) 2008-2011 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	006	19-Jan-2011	BUG: Visual surround broken by previous change,
"				need to explicitly specify the unnamed register,
"				or it'll be just aliased to the small delete
"				register, and then the setreg() will unalias,
"				and the register contents suddenly are
"				different! 
"				FIX: Still clobbering of unnamed register for
"				selectionType = 'z'; now using the black hole
"				register. 
"	005	14-Jan-2011	FIX: Visual surround clobbered the unnamed
"				register; now using the unnamed register and
"				also saving the register mode. 
"	004	24-Feb-2010	ENH: Supporting multi-word surrounding via
"				supplied [count]. Evaluating v:count1 for
"				selectionType 'w' and 'W'. 
"	003	08-Sep-2009	BF: Replaced mark " and g` command with
"				getpos() / setpos() because m" didn't work on
"				Vim 7.0/7.1, and caused the entire insertion to
"				be aborted. This change also simplifies the
"				logic to correct the saved cursor position,
"				which can now be done with byte offsets instead
"				of character offsets. 
"	002	18-Jun-2009	Replaced temporary mark z with mark " and using
"				g` command to avoid clobbering jumplist. 
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
	execute 'normal! "_s' . a:textBefore . "\<C-R>\<C-O>z" . a:textAfter . "\<Esc>"
    elseif a:selectionType ==# 'v'
	let l:save_clipboard = &clipboard
	set clipboard= " Avoid clobbering the selection and clipboard registers. 
	let l:save_reg = getreg('"')
	let l:save_regmode = getregtype('"')

	normal! gv""s$

	" Set paste type to characterwise; otherwise, linewise selections would
	" be pasted _below_ the surrounded characters. 
	call setreg('"', '', 'av')
	execute 'normal! "_s' . a:textBefore . "\<C-R>\<C-O>\"" . a:textAfter . "\<Esc>"

	call setreg('"', l:save_reg, l:save_regmode)
	let &clipboard = l:save_clipboard
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

	let l:save_cursor = getpos('.')
	execute 'normal! w' . l:backmotion . "i". a:textBefore . "\<Esc>" . v:count1 . l:backendmotion . "a" . a:textAfter . "\<Esc>"

	" Adapt saved cursor position to consider inserted text. 
	let l:save_cursor[2] += strlen(a:textBefore)
	call setpos('.', l:save_cursor)
    endif
endfunction

function! surroundings#SurroundWithSingleChar( selectionType, char )
    call surroundings#SurroundWith( a:selectionType, a:char, a:char )
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
