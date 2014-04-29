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
"   1.019.001	30-Apr-2014	file creation

function! ingo#pos#IsOnOrAfter( lineA, colA, lineB, colB )
    return (a:lineA > a:lineB || a:lineA == a:lineB && a:colA >= a:colB)
endfunction
function! ingo#pos#IsOnOrAfterPos( posA, posB )
    return ingo#pos#IsOnOrAfter(a:posA[0], a:posA[1], a:posB[0], a:posB[1])
endfunction
function! ingo#pos#IsAfter( lineA, colA, lineB, colB )
    return (a:lineA > a:lineB || a:lineA == a:lineB && a:colA > a:colB)
endfunction
function! ingo#pos#IsAfterPos( posA, posB )
    return ingo#pos#IsAfter(a:posA[0], a:posA[1], a:posB[0], a:posB[1])
endfunction

function! ingo#pos#IsOnOrBefore( lineA, colA, lineB, colB )
    return (a:lineA < a:lineB || a:lineA == a:lineB && a:colA <= a:colB)
endfunction
function! ingo#pos#IsOnOrBeforePos( posA, posB )
    return ingo#pos#IsOnOrBefore(a:posA[0], a:posA[1], a:posB[0], a:posB[1])
endfunction
function! ingo#pos#IsBefore( lineA, colA, lineB, colB )
    return (a:lineA < a:lineB || a:lineA == a:lineB && a:colA < a:colB)
endfunction
function! ingo#pos#IsBeforePos( posA, posB )
    return ingo#pos#IsBefore(a:posA[0], a:posA[1], a:posB[0], a:posB[1])
endfunction

function! ingo#pos#IsOutside( line, col, lineS, colS, lineE, colE )
    return (a:line < a:lineS || a:line > a:lineE || a:col < a:colS || a:col > a:colE)
endfunction
function! ingo#pos#IsOutsidePos( pos, start, end )
    return ingo#pos#IsOutside(a:pos[0], a:pos[1], a:start[0], a:start[1], a:end[0], a:end[1])
endfunction

function! ingo#pos#IsInside( line, col, lineS, colS, lineE, colE )
    return ! (a:line < a:lineS || a:line > a:lineE || a:col < a:colS || a:col > a:colE)
endfunction
function! ingo#pos#IsInsidePos( pos, start, end )
    return ingo#pos#IsInside(a:pos[0], a:pos[1], a:start[0], a:start[1], a:end[0], a:end[1])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
