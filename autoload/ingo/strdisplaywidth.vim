" ingo/strdisplaywidth.vim: Functions for dealing with the screen display width of text.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.008.001	07-Jun-2013	file creation from EchoWithoutScrolling.vim.

function! ingo#strdisplaywidth#HasMoreThan( expr, virtCol )
    return (match( a:expr, '^.*\%>' . a:virtCol . 'v' ) != -1)
endfunction
function! ingo#strdisplaywidth#strleft( expr, virtCol )
    " Must add 1 because a "before-column" pattern is used in case the exact
    " column cannot be matched (because its halfway through a tab or other wide
    " character).
    return matchstr(a:expr, '^.*\%<' . (a:virtCol + 1) . 'v')
endfunction
function! s:ReverseStr( expr )
    return join(reverse(split(a:expr, '\zs')), '')
endfunction
function! ingo#strdisplaywidth#strright( expr, virtCol )
    " Virtual columns are always counted from the start, not the end. To specify
    " the column counting from the end, the string is reversed during the
    " matching.
    return s:ReverseStr(ingo#strdisplaywidth#strleft(s:ReverseStr(a:expr), a:virtCol))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
