" ingo/dict.vim: Functions for creating Dictionaries.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.009.001	21-Jun-2013	file creation

function! ingo#dict#FromItems( items )
    let l:dict = {}
    for [l:key, l:val] in a:items
	let l:dict[l:key] = l:val
    endfor
    return l:dict
endfunction

function! ingo#dict#FromKeys( keys, defaultValue )
    let l:dict = {}
    for l:key in a:keys
	let l:dict[l:key] = a:defaultValue
    endfor
    return l:dict
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
