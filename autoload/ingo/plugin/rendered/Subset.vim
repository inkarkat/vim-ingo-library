" ingo/plugin/rendered/Subset.vim: Filter items by List indices.
"
" DEPENDENCIES:
"   - ingo/cmdargs/pattern.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2015-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#plugin#rendered#Subset#Filter( items )
    echohl Question
    let l:subsets = input('Enter subsets in Vim List notation, e.g. "0 3:5 -1", or matching /pattern/ (non-matching with !/.../): ')
    echohl None

    if ingo#cmdargs#pattern#IsDelimited(l:subsets)
	return s:FilterByPattern(a:items, l:subsets[1:-2], 0)
    elseif l:subsets[0] == '!' && ingo#cmdargs#pattern#IsDelimited(l:subsets[1:])
	return s:FilterByPattern(a:items, l:subsets[2:-2], 1)
    else
	return s:Slice(a:items, split(l:subsets))
    endif
endfunction

function! s:FilterByPattern( items, pattern, isKeepNonMatching )
    return filter(a:items, printf('v:val %s~ a:pattern', a:isKeepNonMatching ? '!' : '='))
endfunction

function! s:Slice( items, subsets )
    try
	let l:subsetItems = []
	for l:subset in a:subsets
	    execute printf('let l:subsetItems += ingo#list#Make(a:items[%s])', l:subset)
	endfor
	return l:subsetItems
    catch /^Vim\%((\a\+)\)\=:/
	redraw
	call ingo#msg#VimExceptionMsg()
	sleep 500m
	return ingo#plugin#rendered#Subset#Filter(a:items)
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
