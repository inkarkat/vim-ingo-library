" ingo/hlgroup.vim: Functions around highlight groups.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.001	09-Feb-2017	file creation

function! ingo#hlgroup#LinksTo( name )
    return synIDattr(synIDtrans(hlID(a:name)), 'name')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
