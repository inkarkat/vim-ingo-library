" ingo/matches.vim: Functions for pattern matching.
"
" DEPENDENCIES:
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2013-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:Count()
    let s:matchCnt += 1
    return submatch(0)
endfunction
function! ingo#matches#CountMatches( text, pattern )
    let s:matchCnt = 0
    for l:line in ingo#list#Make(a:text)
	call substitute(l:line, a:pattern, '\=s:Count()', 'g')
    endfor
    return s:matchCnt
endfunction


function! ingo#matches#Any( text, patterns )
    for l:pattern in a:patterns
	if a:text =~# l:pattern
	    return 1
	endif
    endfor
    return empty(a:patterns)
endfunction
function! ingo#matches#All( text, patterns )
    for l:pattern in a:patterns
	if a:text !~# l:pattern
	    return 0
	endif
    endfor
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
