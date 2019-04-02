" surroundings.vim: Generic functions to surround text with something.
"
" DEPENDENCIES:
"   - ingo/cursor/move.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/register.vim autoload script
"
" Copyright: (C) 2008-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	016	26-May-2014	Use cursor() instead of setpos('.') to set the
"				curswant column for subsequent vertical movement.
"	015	18-Nov-2013	Use ingo#register#KeepRegisterExecuteOrFunc().
"	014	03-Jul-2013	Move ingocursormove.vim into ingo-library.
"	013	08-May-2013	Use ingo-library for warning messages.
"				FIX: Used :normal clobbers used [count];
"				instead, pass it into
"				surroundings#ChangeEnclosedText(),
"				surroundings#RemoveSingleCharDelimiters(),
"				surroundings#RemoveDelimiters().
"				ENH: Mark the changed area where the delimiters
"				were removed. This makes it easier to further
"				work with it (e.g. to re-surround with a
"				different delimiter).
"				ENH: Mark the changed area where delimiters
"				where added (including the delimiters).
"				ENH: For v_<Leader>i, show the original text
"				surrounded by $, not just a simple $
"				replacement, while querying for the surrounding
"				character.
"	012	21-Mar-2013	Avoid changing the jumplist.
"	011	07-Jan-2013	Factor out s:CursorLeft() and s:CursorRight() to
"				autoload/ingocursormove.vim for re-use.
"	010	11-Sep-2012	ENH: Support use of surroundings#SurroundWith()
"				in custom operator via g@.
"	009	28-Aug-2012	I18N: FIX: s:CursorLeft() and s:CursorRight()
"				didn't consider multi-byte characters. Use h / l
"				commands instead of de-/incrementing cursor
"				column; we've already determined that it's
"				possible to move there.
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
function! surroundings#ChangeEnclosedText( count, delimiterChar, isInner )
    let l:save_cursor = getpos('.')
    let l:literalDelimiterExpr = s:Literal(a:delimiterChar)

    " Special case: select nothing (by doing nothing :-) when inner change (with
    " count=1) and there are no or only newlines between the delimiters.
    " Once we're in Visual mode, at least the current char will be changed;
    " there is no 'null' selection possible.
    if ! ( (search( '\%#' . l:literalDelimiterExpr . '\n*' . l:literalDelimiterExpr ) > 0) && a:count == 1 && a:isInner )
	" Step right to consider the cursor position and search for leading
	" delimiter to the left.
	call ingo#cursor#move#Right()
	if s:Search(l:literalDelimiterExpr, 1, 1) > 0
	    if( a:isInner )
		call ingo#cursor#move#Right()
		normal! v
		call ingo#cursor#move#Left()
	    else
		normal! v
	    endif

	    " Now that we're in Visual mode, extend the selection until the
	    " trailing delimiter by searching to the right (from the original
	    " cursor position).
	    call setpos('.', l:save_cursor)
	    if s:Search(l:literalDelimiterExpr, a:count, 0) > 0
		if( ! a:isInner )
		    call ingo#cursor#move#Right()
		endif
	    else
		normal! v
		call setpos('.', l:save_cursor)
		call ingo#msg#WarningMsg('Trailing ' . a:delimiterChar . ' not found')
	    endif
	else
	    call setpos('.', l:save_cursor)
	    call ingo#msg#WarningMsg('Leading ' . a:delimiterChar . ' not found')
	endif
    endif
endfunction

" Based on the cursor position, remove the passed 'delimiterChar' from the
" left and right. Text between delimiters can be across multiple lines or
" empty and will not be touched. If the cursor rests already ON a delimiter,
" this one is taken as the first delimiter.
function! surroundings#RemoveSingleCharDelimiters( count, delimiterChar )
    " This is the simplest algorithm; first search left for the leading delimiter,
    " then (from the original cursor position) in the other direction for the
    " trailing one. If both are found, remove the trailing and then the
    " (memorized) lead delimiter.
    let l:save_cursor = getpos('.')
    let l:literalDelimiterExpr = s:Literal(a:delimiterChar)

    " If the cursor rests already ON a delimiter, this one is taken as the first delimiter.
    call ingo#cursor#move#Right()
    if s:Search(l:literalDelimiterExpr, 1, 1) > 0
	let l:begin_cursor = getpos('.')
	call setpos('.', l:save_cursor)
	if s:Search(l:literalDelimiterExpr, a:count, 0) > 0
	    " Remove the trailing delimiter.
	    normal! "_x

	    " Determine the end position; when the leading delimiter is in the
	    " same line, this needs further adjustment.
	    call ingo#cursor#move#Left(l:begin_cursor[1] == line('.') ? 2 : 1)
	    let l:end_pos = getpos('.')

	    " Delete the leading delimiter.
	    call setpos('.', l:begin_cursor)
	    normal! "_x

	    " Mark the changed area.
	    call setpos("'[", getpos('.'))
	    call setpos("']", l:end_pos)
	else
	    call ingo#msg#WarningMsg('Trailing ' . a:delimiterChar . ' not found')
	endif
    else
	call ingo#msg#WarningMsg('Leading ' . a:delimiterChar . ' not found')
    endif
    call setpos('.', l:save_cursor)
endfunction

function! s:RemoveExprFromCursorPosition( expr )
    let l:save_col = col('.')
	let l:beforeLen = len(getline('.'))
	    execute 's/\%#' . a:expr . '//e'
	let l:afterLen = len(getline('.'))
    call cursor(0, l:save_col)

    return (l:beforeLen - l:afterLen)
endfunction
" Based on the cursor position, remove the passed delimiters from the
" left and right. Delimiters can be single chars or patterns. Text between
" delimiters can be across multiple lines or empty and will not be touched.
" The cursor must rest before the trailing delimiter.
function! surroundings#RemoveDelimiters( count, leadingDelimiterPattern, trailingDelimiterPattern, ... )
    " To cope with different delimiters, we first do a forward search for the
    " trailing delimiter, then go the other direction to the leading one.
    " Memorizing its position, it's back to the trailing one, which is
    " removed. Finally, the leading one is removed. This back-and-forth is
    " necessary because the replacement of delimiters changes the former
    " positions.
    let l:save_cursor = getpos('.')
    let l:literalLeadingDelimiterExpr  = '\V' . a:leadingDelimiterPattern
    let l:literalTrailingDelimiterExpr = '\V' . a:trailingDelimiterPattern

    if s:Search( l:literalTrailingDelimiterExpr, a:count, 0 ) > 0
	call setpos('.', l:save_cursor)
	if s:Search( l:literalLeadingDelimiterExpr, 1, 1 ) > 0
	    let l:begin_cursor = getpos('.')
	    call setpos('.', l:save_cursor)
	    if s:Search( l:literalTrailingDelimiterExpr, a:count, 0 ) > 0
		" Remove the trailing delimiter.
		call s:RemoveExprFromCursorPosition(l:literalTrailingDelimiterExpr)

		" Determine the end position.
		call ingo#cursor#move#Left()
		let l:end_pos = getpos('.')

		" Remove the leading delimiter.
		call setpos('.', l:begin_cursor)
		let l:beginByteDiff = s:RemoveExprFromCursorPosition(l:literalLeadingDelimiterExpr)

		" Adjust the end position when the leading delimiter is in the
		" same line.
		if l:begin_cursor[1] == l:end_pos[1]
		    let l:end_pos[2] -= l:beginByteDiff
		endif

		" Mark the changed area.
		call setpos("'[", getpos('.'))
		call setpos("']", l:end_pos)
	    else
		throw "ASSERT: Trailing delimiter shouldn't vanish. "
	    endif
	else
	    call ingo#msg#WarningMsg('Leading ' . (a:0 ? a:1 : a:leadingDelimiterPattern) . ' not found')
	endif
    else
	call ingo#msg#WarningMsg('Trailing ' . (a:0 ? a:1 : a:trailingDelimiterPattern) . ' not found')
    endif
    call setpos('.', l:save_cursor)
endfunction



function! surroundings#DoSurround( textBefore, textAfter )
    normal! gv""s$

    " Set paste type to characterwise; otherwise, linewise selections would be
    " pasted _below_ the surrounded characters.
    call setreg('"', '', 'av')
    execute 'normal! "_s' . a:textBefore . "\<C-R>\<C-O>\"" . a:textAfter . "\<Esc>"
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
	execute 'normal! g`[' . visualmode() . 'g`]"_c' . a:textBefore . "\<C-R>\<C-O>z" . a:textAfter . "\<Esc>"

	" Mark the changed area.
	" The start of the change is already right, but the end is one after the
	" trailing delimiter. Use the cursor position instead, it is right.
	call setpos("']", getpos('.'))
    elseif index(['v', 'char', 'line', 'block'], a:selectionType) != -1
	if a:selectionType ==# 'char'
	    silent! execute 'normal! g`[vg`]'. (&selection ==# 'exclusive' ? 'l' : '') . "\<Esc>"
	elseif a:selectionType ==# 'line'
	    silent! execute "normal! g'[Vg']\<Esc>"
	elseif a:selectionType ==# 'block'
	    silent! execute "normal! g`[\<C-V>g`]". (&selection ==# 'exclusive' ? 'l' : '') . "\<Esc>"
	endif

	call ingo#register#KeepRegisterExecuteOrFunc(function('surroundings#DoSurround'), a:textBefore, a:textAfter)

	" Mark the changed area.
	" The start of the change is already right, but the end is one after the
	" trailing delimiter. Use the cursor position instead, it is right.
	call setpos("']", getpos('.'))
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

	let l:count = (v:count ? v:count : '')
	let l:save_cursor = getpos('.')
	execute 'normal! w' . l:backmotion . "i". a:textBefore . "\<Esc>"
	let l:begin_pos = getpos("'[")

	execute 'normal!' l:count . l:backendmotion . "a" . a:textAfter . "\<Esc>"
	let l:end_pos = getpos(".") " Use the cursor position; '] is one after the change.

	" Adapt saved cursor position to consider inserted text.
	let l:save_cursor[2] += strlen(a:textBefore)
	call cursor(l:save_cursor[1:2]) " Use cursor() instead of setpos('.') to set the curswant column for subsequent vertical movement.

	" Mark the changed area.
	call setpos("'[", l:begin_pos)
	call setpos("']", l:end_pos)
    endif
endfunction

function! surroundings#SurroundWithSingleChar( selectionType, char )
    call surroundings#SurroundWith( a:selectionType, a:char, a:char )
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
