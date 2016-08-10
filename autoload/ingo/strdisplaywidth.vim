" ingo/strdisplaywidth.vim: Functions for dealing with the screen display width of text.
"
" DEPENDENCIES:
"   - ingo/str.vim autoload script
"
" Copyright: (C) 2008-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.004	29-Dec-2014	Add ingo#strdisplaywidth#TruncateTo().
"   1.019.003	17-Apr-2014	Add ingo#strdisplaywidth#GetMinMax().
"   1.011.002	26-Jul-2013	FIX: Off-by-one in
"				ingo#strdisplaywidth#HasMoreThan() and
"				ingo#strdisplaywidth#strleft().
"				Factor out ingo#str#Reverse().
"   1.008.001	07-Jun-2013	file creation from EchoWithoutScrolling.vim.

function! ingo#strdisplaywidth#HasMoreThan( expr, virtCol )
    return (match(a:expr, '^.*\%>' . (a:virtCol + 1) . 'v') != -1)
endfunction

function! ingo#strdisplaywidth#GetMinMax( lines, ... )
    let l:col = (a:0 ? a:1 : 0)
    let l:widths = map(copy(a:lines), 'ingo#compat#strdisplaywidth(v:val, l:col)')
    return [min(l:widths), max(l:widths)]
endfunction

function! ingo#strdisplaywidth#strleft( expr, virtCol )
    " Must add 1 because a "before-column" pattern is used in case the exact
    " column cannot be matched (because its halfway through a tab or other wide
    " character), and include that before-column in the match, too.
    return matchstr(a:expr, '^.*\%<' . (a:virtCol + 1) . 'v.')
endfunction
function! ingo#strdisplaywidth#TruncateTo( text, virtCol, ... )
"******************************************************************************
"* PURPOSE:
"   Truncate a:text to a maximum of a:virtCol virtual columns, and if this
"   happens, indicate via an appended "..." indicator.
"* SEE ALSO:
"   - ingo#avoidprompt#TruncateTo() does something similar with truncation in
"     the middle of a:text, not at the end, but it is meant for :echoing, as
"     it accounts for buffer-local tabstop values.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text	Text which may be truncated to fit.
"   a:virtCol   Maximum virtual columns for a:text.
"   a:truncationIndicator   Optional text to be appended when truncation
"			    appears. a:text is further reduced to account for
"			    its width. Default is "...".
"* RETURN VALUES:
"   Truncated a:text.
"******************************************************************************
    let l:truncationIndicator = (a:0 ? a:1 : '...')
    if ingo#strdisplaywidth#HasMoreThan(a:text, a:virtCol)
	let l:truncatedText = ingo#strdisplaywidth#strleft(a:text, max([0, a:virtCol - ingo#compat#strdisplaywidth(l:truncationIndicator)]))
	return l:truncatedText . l:truncationIndicator
    else
	return a:text
    endif
endfunction

function! ingo#strdisplaywidth#strright( expr, virtCol )
    " Virtual columns are always counted from the start, not the end. To specify
    " the column counting from the end, the string is reversed during the
    " matching.
    return ingo#str#Reverse(ingo#strdisplaywidth#strleft(ingo#str#Reverse(a:expr), a:virtCol))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
