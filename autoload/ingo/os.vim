" ingo/os.vim: Functions for operating system-specific stuff.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.012.001	08-Aug-2013	file creation

function! ingo#os#isWindows()
    return has('win16') || has('win95') || has('win32') || has('win64')
endfunction

function! ingo#os#isWinOrDos()
    return has('dos16') || has('dos32') || ingo#os#isWindows()
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
