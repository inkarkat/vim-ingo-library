" ingo/buffer.vim: Functions for buffer information.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.014.003	07-Oct-2013	Add ingo#buffer#IsPersisted(), taken from
"				autoload/ShowTrailingWhitespace/Filter.vim.
"   1.010.002	08-Jul-2013	Add ingo#buffer#IsEmpty().
"   1.006.001	29-May-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! ingo#buffer#IsEmpty()
    return line('$') == 1 && empty(getline(1))
endfunction

function! ingo#buffer#IsBlank( bufnr )
    return (empty(bufname(a:bufnr)) &&
    \ getbufvar(a:bufnr, '&modified') == 0 &&
    \ empty(getbufvar(a:bufnr, '&buftype'))
    \)
endfunction

function! ingo#buffer#IsPersisted( ... )
    let l:bufType = (a:0 ? getbufvar(a:1, '&buftype') : &l:buftype)
    return (empty(l:bufType) || l:bufType ==# 'acwrite')
endfunction

function! ingo#buffer#ExistOtherBuffers( targetBufNr )
    return ! empty(filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != a:targetBufNr'))
endfunction

function! ingo#buffer#IsEmptyVim()
    let l:currentBufNr = bufnr('')
    return ingo#buffer#IsBlank(l:currentBufNr) && ! ingo#buffer#ExistOtherBuffers(l:currentBufNr)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
