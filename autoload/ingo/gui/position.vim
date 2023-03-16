" ingo/gui/position.vim: Functions for the GVIM position and size.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013-2023 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if exists('*getwinpos')
    function! ingo#gui#position#Get() abort
	return [&columns, &lines] + getwinpos()
    endfunction
else
    function! ingo#gui#position#Get() abort
	redir => l:winpos
	    silent! winpos
	redir END
	return [&columns, &lines, str2nr(matchstr(l:winpos, '\CX \zs-\?\d\+')), str2nr(matchstr(l:winpos, '\CY \zs-\?\d\+'))]
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
