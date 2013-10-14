" ingo/filetype.vim: Functions for the buffer's filetype(s).
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.011.001	22-Jul-2013	file creation from ingointegration.vim.

function! ingo#filetype#Is( filetypes )
    let l:filetypes = (type(a:filetypes) == type([]) ? a:filetypes : [a:filetypes])

    for l:ft in split(&filetype, '\.')
	if (index(l:filetypes, l:ft) != -1)
	    return 1
	endif
    endfor

    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
