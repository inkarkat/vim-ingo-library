" ingo/str.vim: String functions.
"
" DEPENDENCIES:
"   - ingo/regexp/collection.vim autoload script
"   - ingo/regexp/virtcols.vim autoload script
"
" Copyright: (C) 2013-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.027.007	30-Sep-2016	Add ingo#str#trd().
"   1.025.006	30-Apr-2015	Add ingo#str#Contains().
"   1.024.005	01-Apr-2015	Add ingo#str#GetVirtCols().
"   1.019.004	21-May-2014	Allow optional a:ignorecase argument for
"				ingo#str#StartsWith() and ingo#str#EndsWith().
"				Add ingo#str#Equals() for when it's convenient
"				to pass in the a:ignorecase flag. This avoids
"				coding the conditional between ==# and ==?
"				yourself.
"   1.016.003	23-Dec-2013	Add ingo#str#StartsWith() and
"				ingo#str#EndsWith().
"   1.011.002	26-Jul-2013	Add ingo#str#Reverse().
"   1.009.001	19-Jun-2013	file creation

function! ingo#str#Trim( string )
"******************************************************************************
"* PURPOSE:
"   Remove all leading and trailing whitespace from a:string.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:string    Text.
"* RETURN VALUES:
"   a:string with leading and trailing whitespace removed.
"******************************************************************************
    return substitute(a:string, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

function! ingo#str#Reverse( string )
    return join(reverse(split(a:string, '\zs')), '')
endfunction

function! ingo#str#StartsWith( string, substring, ... )
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return (strpart(a:string, 0, len(a:substring)) ==? a:substring)
    else
	return (strpart(a:string, 0, len(a:substring)) ==# a:substring)
    endif
endfunction
function! ingo#str#EndsWith( string, substring, ... )
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return (strpart(a:string, len(a:string) - len(a:substring)) ==? a:substring)
    else
	return (strpart(a:string, len(a:string) - len(a:substring)) ==# a:substring)
    endif
endfunction

function! ingo#str#Equals( string1, string2, ...)
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return a:string1 ==? a:string2
    else
	return a:string1 ==# a:string2
    endif
endfunction
function! ingo#str#Contains( string, part, ...)
    let l:ignorecase = (a:0 && a:1)
    if l:ignorecase
	return (stridx(a:string, a:part) != -1 || a:string =~? '\V' . escape(a:part, '\'))
    else
	return (stridx(a:string, a:part) != -1)
    endif
endfunction

function! ingo#str#GetVirtCols( string, virtcol, width, isAllowSmaller )
"******************************************************************************
"* PURPOSE:
"   Get a:width screen columns of a:string at a:virtcol.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:virtcol   First virtual column (first column is 1); the character must
"		begin exactly at that column.
"   a:width     Width in screen columns.
"   a:isAllowSmaller    Boolean flag whether less characters can be matched if
"			the end doesn't fall on a character border, or there
"			aren't that many characters. Else, exactly a:width
"			screen columns must be matched.
"* RETURN VALUES:
"   Text starting at a:virtcol with a (maximal) width of a:width.
"******************************************************************************
    if a:virtcol < 1
	throw 'GetVirtCols: Column must be at least 1'
    endif
    return matchstr(a:string, ingo#regexp#virtcols#ExtractCells(a:virtcol, a:width, a:isAllowSmaller))
endfunction

function! ingo#str#trd( src, fromstr )
"******************************************************************************
"* PURPOSE:
"   Delete characters in a:fromstr in a copy of a:src. Like tr -d, but the
"   built-in tr() doesn't support this.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:src   Source string.
"   a:fromstr   Characters that will each be removed from a:src.
"* RETURN VALUES:
"   Copy of a:src that has all instances of the characters in a:fromstr removed.
"******************************************************************************
    return substitute(a:src, '\C' . ingo#regexp#collection#LiteralToRegexp(a:fromstr), '', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
