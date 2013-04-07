" MultibyteVirtcol.vim: Multibyte-aware translation functions from col() to
" virtcol(). 
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
"   Put the script into your user or system Vim autoload directory (e.g.
"   ~/.vim/autoload). 

" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 

" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	02-Jul-2009	file creation from EchoLine.vim. 

function! MultibyteVirtcol#GetVirtStartColOfCurrentCharacter( lineNum, column )
    let l:currentVirtCol = MultibyteVirtcol#GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column - l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset]) + 1
endfunction
function! MultibyteVirtcol#GetVirtColOfCurrentCharacter( lineNum, column )
    " virtcol() only returns the (end) virtual column of the current character
    " if the column points to the first byte of a multi-byte character. If we're
    " pointing to the middle or end of a multi-byte character, the end virtual
    " column of the _next_ character is returned. 
    let l:offset = 0
    while virtcol([a:lineNum, a:column - l:offset]) == virtcol([a:lineNum, a:column + 1])
	" If the next column's virtual column is the same, we're in the middle
	" of a multi-byte character, and must backtrack to get this character's
	" virtual column. 
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset])
endfunction
function! MultibyteVirtcol#GetVirtColOfNextCharacter( lineNum, column )
    let l:currentVirtCol = MultibyteVirtcol#GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column + l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column + l:offset])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
