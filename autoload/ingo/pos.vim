" ingo/pos.vim: Functions for comparing positions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.022.002	21-Jul-2014	Add ingo#pos#Before() and ingo#pos#After().
"   1.019.001	30-Apr-2014	file creation

function! ingo#pos#IsOnOrAfter( posA, posB )
    return (a:posA[0] > a:posB[0] || a:posA[0] == a:posB[0] && a:posA[1] >= a:posB[1])
endfunction
function! ingo#pos#IsAfter( posA, posB )
    return (a:posA[0] > a:posB[0] || a:posA[0] == a:posB[0] && a:posA[1] > a:posB[1])
endfunction

function! ingo#pos#IsOnOrBefore( posA, posB )
    return (a:posA[0] < a:posB[0] || a:posA[0] == a:posB[0] && a:posA[1] <= a:posB[1])
endfunction
function! ingo#pos#IsBefore( posA, posB )
    return (a:posA[0] < a:posB[0] || a:posA[0] == a:posB[0] && a:posA[1] < a:posB[1])
endfunction

function! ingo#pos#IsOutside( pos, start, end )
    return (a:pos[0] < a:start[0] || a:pos[0] > a:end[0] || a:pos[0] == a:start[0] && a:pos[1] < a:start[1] || a:pos[0] == a:end[0] && a:pos[1] > a:end[1])
endfunction

function! ingo#pos#IsInside( pos, start, end )
    return ! ingo#pos#IsOutside(a:pos, a:start, a:end)
endfunction


function! ingo#pos#Before( pos )
    let l:charBeforePosition = matchstr(getline(a:pos[0]), '.\%' . a:pos[1] . 'c')
    return (empty(l:charBeforePosition) ? [0, 0] : [a:pos[0], a:pos[1] - len(l:charBeforePosition)])
endfunction
function! ingo#pos#After( pos )
    let l:charAtPosition = matchstr(getline(a:pos[0]), '\%' . a:pos[1] . 'c.')
    return (empty(l:charAtPosition) ? [0, 0] : [a:pos[0], a:pos[1] + len(l:charAtPosition)])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
