" ingo/external.vim: Functions to launch an external Vim instance.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.000.001	28-Jan-2013	file creation from DropQuery.vim

let s:exCommandForExternalGvim = (has('win32') || has('win64') ? 'silent !start gvim' : 'silent ! gvim')
function! ingo#external#LaunchGvim( commands )
    execute s:exCommandForExternalGvim join(map(a:commands, '"-c " . escapings#shellescape(v:val, 1)'))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
