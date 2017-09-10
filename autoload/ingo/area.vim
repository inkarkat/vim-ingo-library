" ingo/area.vim: Functions to deal with areas.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#area#IsEmpty( area )
    if empty(a:area)
	return 1
    elseif a:area[0][0] == 0 || a:area[1][0] == 0
	return 1
    elseif a:area[0] == a:area[1]
	return 1
    endif
    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
