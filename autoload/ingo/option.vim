" ingo/option.vim: Functions for dealing with Vim options.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.001	03-Jun-2014	file creation

function! ingo#option#Split( optionValue, ... )
    return call('split', [a:optionValue, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!,'] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
