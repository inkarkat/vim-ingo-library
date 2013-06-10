" ingo/regexp/previoussubstitution.vim: Function to get the previous substitution |s~|
"
" DEPENDENCIES:
"   - ingo/buffer/temp.vim autoload script
"
" Copyright: (C) 2011-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	11-Jun-2013	file creation from ingomappings.vim

function! ingo#regexp#previoussubstitution#Get()
    " The substitution string is not exposed via a Vim variable, nor does
    " substitute() recognize it. We have to perform a substitution in a scratch
    " buffer to obtain it.
    return ingo#buffer#temp#Execute('substitute/^/' . (&magic ? '~' : '\~') . '/')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
