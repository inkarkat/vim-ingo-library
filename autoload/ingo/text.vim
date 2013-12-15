" ingo/text.vim: Function for getting text from the current buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.002	21-Oct-2013	Add ingo#text#GetChar().
"   1.011.001	23-Jul-2013	file creation from ingocommands.vim.

function! ingo#text#Get( startPos, endPos )
"*******************************************************************************
"* PURPOSE:
"   Extract the text between a:startPos and a:endPos from the current buffer.
"   Multiple lines will be delimited by a newline character.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:startPos	    [line,col]
"   a:endPos	    [line,col]
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
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:startPos	    [line,col]
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
