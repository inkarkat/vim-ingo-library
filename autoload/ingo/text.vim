" ingo/text.vim: Function for getting and setting text in the current buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.003	16-Dec-2013	Add ingo#text#Insert() and ingo#text#Remove().
"   1.014.002	21-Oct-2013	Add ingo#text#GetChar().
"   1.011.001	23-Jul-2013	file creation from ingocommands.vim.

function! ingo#text#Get( startPos, endPos )
"*******************************************************************************
"* PURPOSE:
"   Extract the text between a:startPos and a:endPos from the current buffer.
"   Multiple lines will be delimited by a newline character.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startPos	    [line, col]
"   a:endPos	    [line, col]
"* RETURN VALUES:
"   string text
"*******************************************************************************
    let [l:line, l:column] = a:startPos
    let [l:endLine, l:endColumn] = a:endPos
    if l:line > l:endLine || (l:line == l:endLine && l:column > l:endColumn)
	return ''
    endif

    let l:text = ''
    while 1
	if l:line == l:endLine
	    let l:text .= matchstr(getline(l:line) . "\n", '\%' . l:column . 'c' . '.*\%' . (l:endColumn + 1) . 'c')
	    break
	else
	    let l:text .= matchstr(getline(l:line) . "\n", '\%' . l:column . 'c' . '.*')
	    let l:line += 1
	    let l:column = 1
	endif
    endwhile
    return l:text
endfunction

function! ingo#text#GetChar( startPos, ... )
"*******************************************************************************
"* PURPOSE:
"   Extract one / a:count character(s) from a:startPos from the current buffer.
"   Only considers the current line.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:startPos	    [line, col]
"   a:count         Optional number of characters to extract; default 1.
"		    If this is a negative number, tries to extract as many as
"		    possible instead of not matching.
"* RETURN VALUES:
"   string text, or empty string if no(t enough) character(s).
"*******************************************************************************
    let [l:line, l:column] = a:startPos
    let [l:count, l:isUpTo] = (a:0 ? (a:1 > 0 ? [a:1, 0] : [-1 * a:1, 1]) : [0, 0])

    return matchstr(getline(l:line), '\%' . l:column . 'c' . '.' . (l:count ? '\{' . (l:isUpTo ? ',' : '') . l:count . '}' : ''))
endfunction

function! ingo#text#Insert( pos, text )
"******************************************************************************
"* PURPOSE:
"   Insert a:text at a:pos.
"* ASSUMPTIONS / PRECONDITIONS:
"   Buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the buffer.
"* INPUTS:
"   a:pos   [line, col]; col is the 1-based byte-index.
"   a:text  String to insert.
"* RETURN VALUES:
"   Flag whether the position existed and insertion was done.
"******************************************************************************
    let [l:lnum, l:col] = a:pos
    if l:lnum > line('$')
	return 0
    endif

    let l:line = getline(l:lnum)
    if l:col > len(l:line) + 1
	return 0
    elseif l:col <= 1
	throw 'Insert: Column must be at least 1'
    endif
    return (setline(l:lnum, strpart(l:line, 0, l:col - 1) . a:text . strpart(l:line, l:col - 1)) == 0)
endfunction
function! ingo#text#Remove( pos, len )
"******************************************************************************
"* PURPOSE:
"   Remove a:len bytes of text at a:pos.
"* ASSUMPTIONS / PRECONDITIONS:
"   Buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the buffer.
"* INPUTS:
"   a:pos   [line, col]; col is the 1-based byte-index.
"   a:len   Number of bytes to remove.
"* RETURN VALUES:
"   Flag whether the position existed and removal was done.
"******************************************************************************
    let [l:lnum, l:col] = a:pos
    if l:lnum > line('$')
	return 0
    endif

    let l:line = getline(l:lnum)
    if l:col > len(l:line)
	return 0
    elseif l:col <= 1
	throw 'Remove(): Column must be at least 1'
    endif
    return (setline(l:lnum, strpart(l:line, 0, l:col - 1) . strpart(l:line, l:col - 1 + a:len)) == 0)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
