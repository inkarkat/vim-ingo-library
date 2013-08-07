" ingo/compat.vim: Functions for backwards compatibility with old Vim versions.
"
" DEPENDENCIES:
"   - ingo/strdisplaywidth.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.008.002	07-Jun-2013	Move EchoWithoutScrolling#DetermineVirtColNum()
"				implementaion in here.
"   1.004.001	04-Apr-2013	file creation

if exists('*strdisplaywidth')
    function! ingo#compat#strdisplaywidth( expr, ... )
	return call('strdisplaywidth', [a:expr] + a:000)
    endfunction
else
    function! ingo#compat#strdisplaywidth( expr, ... )
	let l:expr = (a:0 ? repeat(' ', a:1) . a:expr : a:expr)
	let i = 1
	while 1
	    if ! ingo#strdisplaywidth#HasMoreThan(l:expr, i)
		return i - 1 - (a:0 ? a:1 : 0)
	    endif
	    let i += 1
	endwhile
    endfunction
endif

if exists('*strchars')
    function! ingo#compat#strchars( expr )
	return strchars(a:expr)
    endfunction
else
    function! ingo#compat#strchars( expr )
	return len(split(a:expr, '\zs'))
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
