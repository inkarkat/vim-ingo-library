" ingo/option/listchars.vim: Functions around the listchars option.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#option#listchars#GetValue( element ) abort
"******************************************************************************
"* PURPOSE:
"   Get the character(s) used for showing the a:element setting of 'listchars'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:element   Setting name of 'listchars', e.g. "tab".
"* RETURN VALUES:
"   Character(s) extracted from 'listchars', or empty String.
"******************************************************************************
    let l:elements = split(&listchars, ',') " No need to escape, according to :help 'listchars', "The characters ':' and ',' should not be used."
    let l:elementDict = ingo#dict#FromItems(map(l:elements, 'split(v:val, ":")'))
    return get(l:elementDict, a:element, '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
