" ingo/area/frompattern.vim: Functions to determine an area in the current buffer.
"
" DEPENDENCIES:
"   - ingo/text.vim autoload script
"   - ingo/text/frompattern.vim autoload script
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#area#frompattern#GetHere( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Extract the positions of the match of a:pattern starting from the current
"   cursor position.
"* SEE ALSO:
"   - ingo#text#frompattern#GetHere() returns the match, not the positions.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:lastLine      End line number to search for the start of the pattern.
"		    Optional; defaults to the current line.
"   a:returnValueOnNoSelection  Optional return value if there's no match. If
"				omitted, [[0, 0], [0, 0]] will be returned.
"* RETURN VALUES:
"   [[startLnum, startCol], [endLnum, endCol]], or a:returnValueOnNoSelection.
"   endCol points to the last character, not beyond it!
"******************************************************************************
    let l:startPos = getpos('.')[1:2]
    let l:endPos = searchpos(a:pattern, 'cenW', (a:0 ? a:1 : line('.')))
    if l:endPos == [0, 0]
	return (a:0 >= 2 ? a:2 : [[0, 0], [0, 0]])
    endif
    return [l:startPos, l:endPos]
endfunction
function! ingo#area#frompattern#GetAroundHere( pattern, ... )
"******************************************************************************
"* PURPOSE:
"   Extract the positions of the match of a:pattern starting the match from the
"   current cursor position, but (unlike ingo#area#frompattern#GetHere()), also
"   include matched characters _before_ the current position.
"* SEE ALSO:
"   - ingo#text#frompattern#GetAroundHere() returns the match, not the positions.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:lastLine      End line number to search for the start of the pattern.
"		    Optional; defaults to the current line.
"   a:firstLine     First line number to search for the start of the pattern.
"		    Optional; defaults to the current line.
"   a:returnValueOnNoSelection  Optional return value if there's no match. If
"				omitted, [[0, 0], [0, 0]] will be returned.
"* RETURN VALUES:
"   [[startLnum, startCol], [endLnum, endCol]], or a:returnValueOnNoSelection.
"   endCol points to the last character, not beyond it!
"******************************************************************************
    let l:startPos = searchpos(a:pattern, 'bcnW', (a:0 >= 2 ? a:2 : line('.')))
    if l:startPos == [0, 0]
	return (a:0 >= 3 ? a:3 : [[0, 0], [0, 0]])
    endif
    let l:endPos = searchpos(a:pattern, 'cenW', (a:0 ? a:1 : line('.')))
    if l:endPos == [0, 0]
	return (a:0 >= 3 ? a:3 : [[0, 0], [0, 0]])
    endif
    return [l:startPos, l:endPos]
endfunction


function! ingo#area#frompattern#Get( firstLine, lastLine, pattern, isOnlyFirstMatch, isUnique )
"******************************************************************************
"* PURPOSE:
"   Extract all non-overlapping positions of matches of a:pattern in the
"   a:firstLine, a:lastLine range and return them as a List.
"* SEE ALSO:
"   - ingo#text#frompattern#Get() returns the matches, not the positions.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:firstLine     Start line number to search.
"   a:lastLine      End line number to search.
"   a:pattern       Regular expression to search. 'ignorecase', 'smartcase' and
"		    'magic' applies. When empty, the last search pattern |"/| is
"		    used.
"   a:isOnlyFirstMatch  Flag whether to include only the first match in every
"			line.
"   a:isUnique          Flag whether duplicate matches are omitted from the
"			result. When set, the result will consist of areas with
"			unique content.
"* RETURN VALUES:
"   [[[startLnum, startCol], [endLnum, endCol]], ...], or [].
"   endCol points to the last character, not beyond it!
"******************************************************************************
    let l:save_view = winsaveview()
	let l:areas = []
	let l:matches = {}
	call cursor(a:firstLine, 1)
	let l:isFirst = 1
	while 1
	    let l:startPos = searchpos(a:pattern, (l:isFirst ? 'c' : '') . 'W', a:lastLine)
	    let l:isFirst = 0
	    if l:startPos == [0, 0] | break | endif
	    let l:endPos = searchpos(a:pattern, 'ceW', a:lastLine)
	    if l:endPos == [0, 0] | break | endif
	    if a:isUnique
		let l:match = ingo#text#Get(l:startPos, l:endPos)
		if has_key(l:matches, l:match)
		    continue
		endif
		let l:matches[l:match] = 1
	    endif

	    call add(l:areas, [l:startPos, l:endPos])
"****D echomsg '****' string(l:startPos) string(l:endPos)
	    if a:isOnlyFirstMatch
		normal! $
	    endif
	endwhile
    call winrestview(l:save_view)
    return l:areas
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
