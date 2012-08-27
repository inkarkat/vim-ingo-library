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
" Copyright: (C) 2008-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	008	20-Aug-2012	Do not clobber the default register in
"				surroundings#RemoveSingleCharDelimiters().
"				(Using v:register would be inconsistent with
"				surroundings#RemoveDelimiters() and probably
"				seldom DWIM.)
"				Use :normal! everywhere.
"	007	21-Jan-2012	Move functions from textobjects.vim (renamed to
"				ingounsurround.vim) here.
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

function! s:WarningMsg( text )
    echohl WarningMsg
    let v:warningmsg = a:text
    echomsg v:warningmsg
    echohl None
endfunction

" Helper: move cursor one position left; with possible wrap to preceding line.
" Cursor does not move if at top of file.
function! s:CursorLeft()
    if col('.') > 1
	call cursor( 0, col('.') - 1 )
    elseif line('.') > 1
	call cursor( line('.') - 1, 0 )
	call cursor( 0, col('$') )
    endif
endfunction

" Helper: move cursor one position right; with possible wrap to following line.
" Cursor does not move if at end of file.
function! s:CursorRight()
    if col('.') + 1 < col('$')
	call cursor( 0, col('.') + 1 )
    elseif line('.') < line('$')
	call cursor( line('.') + 1, 1 )
    endif
endfunction

" Helper: Make a:string a literal search expression.
function! s:Literal( string )
    return '\V' . escape(a:string, '\') . '\m'
endfunction

" Helper: Search for a:expr a:count times.
function! s:Search( expr, count, isBackward )
    for i in range(1, a:count)
	let l:lineNum = search( a:expr, (a:isBackward ? 'b' : '').'W' )
	if l:lineNum == 0
	    return 0
	endif
    endfor
    return l:lineNum
endfunction



" Based on the cursor position, visually selects the text delimited by the
" passed 'delimiterChar' to the left and right. Text between delimiters can
" be across multiple lines or empty. If the cursor rests already ON a
" delimiter, this one is taken as the first delimiter.
" The flag 'isInner' determines whether the selection includes the delimiters.
function! surroundings#ChangeEnclosedText( delimiterChar, isInner )
    let l:save_cursor = getpos('.')
    let l:literalDelimiterExpr = s:Literal(a:delimiterChar)

    " Special case: select nothing (by doing nothing :-) when inner change (with
    " count=1) and there are no or only newlines between the delimiters.
    " Once we're in Visual mode, at least the current char will be changed;
    " there is no 'null' selection possible.
    if ! ( (search( '\%#' . l:literalDelimiterExpr . '\n*' . l:literalDelimiterExpr ) > 0) && v:count1 == 1 && a:isInner )
	" Step right to consider the cursor position and search for leading
	" delimiter to the left.
	call s:CursorRight()
	if s:Search( l:literalDelimiterExpr, v:count1, 1 ) > 0
	    if( a:isInner )
		call s:CursorRight()
		normal! v
		call s:CursorLeft()
	    else
		normal! v
	    endif

	    " Now that we're in Visual mode, extend the selection until the
	    " trailing delimiter by searching to the right (from the original
	    " cursor position).
	    call setpos('.', l:save_cursor)
	    if s:Search( l:literalDelimiterExpr, v:count1, 0 ) > 0
		if( ! a:isInner )
		    call s:CursorRight()
		endif
	    else
		normal! v
		call setpos('.', l:save_cursor)
		call s:WarningMsg('Trailing ' . a:delimiterChar . ' not found')
	    endif
	else
	    call setpos('.', l:save_cursor)
	    call s:WarningMsg('Leading ' . a:delimiterChar . ' not found')
	endif
    endif
endfunction

" Based on the cursor position, remove the passed 'delimiterChar' from the
" left and right. Text between delimiters can be across multiple lines or
" empty and will not be touched. If the cursor rests already ON a delimiter,
" this one is taken as the first delimiter.
function! surroundings#RemoveSingleCharDelimiters( delimiterChar )
    " This is the simplest algorithm; first search left for the leading delimiter,
    " then (from the original cursor position) in the other direction for the
    " trailing one. If both are found, remove the trailing and then the
    " (memorized) lead delimiter.
    let l:save_cursor = getpos('.')
    let l:literalDelimiterExpr = s:Literal(a:delimiterChar)

    " If the cursor rests already ON a delimiter, this one is taken as the first delimiter.
    call s:CursorRight()
    if s:Search( l:literalDelimiterExpr, v:count1, 1 ) > 0
	let l:begin_cursor = getpos('.')
	call setpos('.', l:save_cursor)
	if s:Search( l:literalDelimiterExpr, v:count1, 0 ) > 0
	    normal! "_x
	    call setpos('.', l:begin_cursor)
	    normal! "_x
	else
	    call s:WarningMsg('Trailing ' . a:delimiterChar . ' not found')
	endif
    else
	call s:WarningMsg('Leading ' . a:delimiterChar . ' not found')
    endif
    call setpos('.', l:save_cursor)
endfunction

" Based on the cursor position, remove the passed 'delimiters' from the
" left and right. Delimiters can be single chars or patterns. Text between
" delimiters can be across multiple lines or empty and will not be touched.
" The cursor must rest before the trailing delimiter.
function! surroundings#RemoveDelimiters( leadingDelimiter, trailingDelimiter )
    " To cope with different delimiters, we first do a forward search for the
    " trailing delimiter, then go the other direction to the leading one.
    " Memorizing its position, it's back to the trailing one, which is
    " removed. Finally, the leading one is removed. This back-and-forth is
    " necessary because the replacement of delimiters changes the former
    " positions.
    let l:save_cursor = getpos('.')
    let l:literalLeadingDelimiterExpr = s:Literal(a:leadingDelimiter)
    let l:literalTrailingDelimiterExpr = s:Literal(a:trailingDelimiter)

    if s:Search( l:literalTrailingDelimiterExpr, v:count1, 0 ) > 0
	call setpos('.', l:save_cursor)
	if s:Search( l:literalLeadingDelimiterExpr, v:count1, 1 ) > 0
	    let l:begin_cursor = getpos('.')
	    call setpos('.', l:save_cursor)
	    if s:Search( l:literalTrailingDelimiterExpr, v:count1, 0 ) > 0
		execute 's/\%#' . l:literalTrailingDelimiterExpr . '//e'
		call setpos('.', l:begin_cursor)
		execute 's/\%#' . l:literalLeadingDelimiterExpr . '//e'
	    else
		throw "ASSERT: Trailing delimiter shouldn't vanish. "
	    endif
	else
	    call s:WarningMsg('Leading ' . a:leadingDelimiter . ' not found')
	endif
    else
	call s:WarningMsg('Trailing ' . a:trailingDelimiter . ' not found')
    endif
    call setpos('.', l:save_cursor)
endfunction



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
