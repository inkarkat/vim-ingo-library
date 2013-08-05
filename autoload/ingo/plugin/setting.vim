" ingo/plugin/setting.vim: Functions for retrieving plugin settings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.010.004	08-Jul-2013	Add prefix to exception thrown from
"				ingo#plugin#setting#GetFromScope().
"   1.005.003	10-Apr-2013	Move into ingo-library.
"	002	06-Jul-2010	ENH: Now supporting passing of default value
"				instead of throwing exception, like the built-in
"				get().
"	001	04-Sep-2009	file creation

function! ingo#plugin#setting#GetFromScope( variableName, scopeList, ... )
    for l:scope in a:scopeList
	let l:variable = l:scope . ':' . a:variableName
	if exists( l:variable )
	    execute 'return ' . l:variable
	endif
    endfor
    if a:0
	return a:1
    else
	throw "GetFromScope: No variable named '" . a:variableName . "' defined. "
    endif
endfunction

function! ingo#plugin#setting#GetBufferLocal( variableName, ... )
    return call('ingo#plugin#setting#GetFromScope', [a:variableName, ['b', 'g']] + a:000)
endfunction
function! ingo#plugin#setting#GetWindowLocal( variableName, ... )
    return call('ingo#plugin#setting#GetFromScope', [a:variableName, ['w', 'g']] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
