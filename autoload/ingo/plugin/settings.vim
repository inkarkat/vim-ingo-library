" ingoplugin.vim: Custom utility functions for plugins. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2009-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	002	06-Jul-2010	ENH: Now supporting passing of default value
"				instead of throwing exception, like the built-in
"				get(). 
"	001	04-Sep-2009	file creation

function! ingoplugin#GetSettingFromScope( variableName, scopeList, ... )
    for l:scope in a:scopeList
	let l:variable = l:scope . ':' . a:variableName
	if exists( l:variable )
	    execute 'return ' . l:variable
	endif
    endfor
    if a:0
	return a:1
    else
	throw "No variable named '" . a:variableName . "' defined. "
    endif
endfunction

function! ingoplugin#GetBufferLocalSetting( variableName, ... )
    return call('ingoplugin#GetSettingFromScope', [a:variableName, ['b', 'g']] + a:000)
endfunction
function! ingoplugin#GetWindowLocalSetting( variableName, ... )
    return call('ingoplugin#GetSettingFromScope', [a:variableName, ['w', 'g']] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
