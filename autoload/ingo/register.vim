" ingo/register.vim: Functions for accessing Vim registers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.001	09-Jul-2013	file creation

function! ingo#register#Default()
    let l:values = split(&clipboard, ',')
    if index(l:values, 'unnamedplus') != -1
        return '+'
    elseif index(l:values, 'unnamed') != -1
        return '*'
    else
        return '"'
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
