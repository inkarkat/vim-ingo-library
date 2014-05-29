" ingo/text/replace.vim: Functions to replace a pattern with text.
"
" DEPENDENCIES:
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.005	23-Jul-2013	Move into ingo-library.
"	004	11-Apr-2013	ENH: ingoreplacer#ReplaceText() returns
"				structure with the original and replaced text.
"				Use ingo#msg#WarningMsg() from ingo-library.
"				Extract user output into separate
"				ingoreplacer#ReplaceTextWithMessage() function.
"	003	07-May-2012	As an optimization, use l:maxCount for "last"
"				location when already determined by "current" location.
"	002	06-May-2012	ENH: Change default strategy to current match,
"				then next match (instead of last match), and
"				allow passing of different strategy of choosing
"				the match locations.
"	001	06-May-2012	file creation from plugin/InsertDate.vim

function! s:ReplaceRange( source, startIdx, endIdx, string )
    return strpart(a:source, 0, a:startIdx) . a:string . strpart(a:source, a:endIdx + 1)
endfunction

function! s:ReplaceTextInRange( startIdx, endIdx, text )
    let l:line = getline('.')
    let l:currentText = strpart(l:line, a:startIdx, (a:endIdx - a:startIdx + 1))
"**** echo 'current ' . l:currentText . ', new ' . a:text
    if l:currentText !=# a:text
	return (setline('.', s:ReplaceRange(l:line, a:startIdx, a:endIdx, a:text)) ? '' : l:currentText)
    else
	" The range already contains the new text in the correct format, no
	" replacement was done.
	return ''
    endif
endfunction

function! ingo#text#replace#PatternWithText( pattern, text, ... )
"******************************************************************************
"* PURPOSE:
"   Replace occurrences of a:pattern in the current line with a:text.
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current line.
"* INPUTS:
"   a:pattern   Regular expression that defines the text to replace.
"   a:text      Replacement text.
"   a:strategy  Array of locations where in the current line a:pattern will
"		match. Possible values: 'current', 'next', 'last'. The default
"		is ['current', 'next'], to have the same behavior as the
"		built-in "*" command.
"* RETURN VALUES:
"   Object with replacement information: {'startIdx', 'endIdx', 'original',
"   'replacement', 'where'}, or empty Dictionary if no replacement was done.
"******************************************************************************
    let l:strategy = (a:0 ? copy(a:1) : ['current', 'next'])

    " Because of setline(), we can only (easily) handle text replacement in a
    " single line, so replace with the first (non-empty) line only should the
    " replacement text consists of multiple lines.
    let l:text = split(a:text, "\n")[0]

    " Substitute any of the text patterns with the current text in the current
    " text format.
    let l:line = getline('.')

    while ! empty(l:strategy)
	let l:location = remove(l:strategy, 0)
	if l:location ==# 'current'
	    " If the cursor is positioned on a text, update that one.
	    let l:cursorIdx = col('.') - 1
	    let l:startIdx = 0
	    let l:count = 0
	    while l:startIdx != -1
		let l:count += 1
		let l:startIdx = match(l:line, a:pattern, 0, l:count)
		let l:endIdx = matchend(l:line, a:pattern, 0, l:count) - 1
		if l:startIdx <= l:cursorIdx && l:cursorIdx <= l:endIdx
"****D echomsg '**** cursor match from ' . l:startIdx . ' to ' . l:endIdx
		    let l:originalText = s:ReplaceTextInRange(l:startIdx, l:endIdx, l:text)
		    if ! empty(l:originalText)
			return {'startIdx': l:startIdx, 'endIdx': l:endIdx, 'original': l:originalText, 'replacement': l:text, 'where': '%s at cursor position'}
		    endif
		endif
	    endwhile
	    let l:maxCount = l:count
	elseif l:location ==# 'next'
	    " Update the next text (that is not already the current text and
	    " format) found in the line.
	    let l:cursorIdx = col('.') - 1
	    let l:startIdx = 0
	    let l:count = 0
	    while l:startIdx != -1
		let l:count += 1
		let l:startIdx = match(l:line, a:pattern, l:cursorIdx, l:count)
		let l:endIdx = matchend(l:line, a:pattern, l:cursorIdx, l:count) - 1
"****D echomsg '**** next match from ' . l:startIdx . ' to ' . l:endIdx
		if l:startIdx != -1
		    let l:originalText = s:ReplaceTextInRange(l:startIdx, l:endIdx, l:text)
		    if ! empty(l:originalText)
			call cursor(line('.'), l:startIdx + 1)
			return {'startIdx': l:startIdx, 'endIdx': l:endIdx, 'original': l:originalText, 'replacement': l:text, 'where': 'next %s in line'}
		    endif
		endif
	    endwhile
	elseif l:location ==# 'last'
	    " Update the last text (that is not already the current text and
	    " format) found in the line. This will update non-current texts from last to
	    " first on subsequent invocations until all occurrences are current.
	    let l:count = (exists('l:maxCount') ? l:maxCount - 1 : len(l:line))   " XXX: This is ineffective but easier than first counting the matches.
	    while l:count > 0
		let l:startIdx = match(l:line, a:pattern, 0, l:count)
		let l:endIdx = matchend(l:line, a:pattern, 0, l:count) - 1
"****D echomsg '**** last match from ' . l:startIdx . ' to ' . l:endIdx . ' at count ' . l:count
		if l:startIdx != -1
		    let l:originalText = s:ReplaceTextInRange(l:startIdx, l:endIdx, l:text)
		    if ! empty(l:originalText)
			call cursor(line('.'), l:startIdx + 1)
			return {'startIdx': l:startIdx, 'endIdx': l:endIdx, 'original': l:originalText, 'replacement': l:text, 'where': 'last %s in line'}
		    endif
		endif
		let l:count -= 1
	    endwhile
	else
	    throw 'ASSERT: Unknown strategy location: ' . l:location
	endif
    endwhile

    return {}
endfunction
function! ingo#text#replace#PatternWithTextAndMessage( what, pattern, text, ... )
    let l:replacement = call('ingo#text#replace#PatternWithText', [a:pattern, a:text] + a:000)
    if empty(l:replacement)
	call ingo#msg#WarningMsg(printf('No %s was found in this line', a:what))
    else
	echo 'Updated' printf(l:replacement.where, a:what)
    endif
    return l:replacement
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
