" ingo/math.vim: Mathematical functions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	27-Dec-2016	file creation

function! ingo#math#BitsRequired( num )
"******************************************************************************
"* PURPOSE:
"   Determine the number of bits required to represent a:num.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:num   Positive integer.
"* RETURN VALUES:
"   Number of bits required to represent numbers between 0 and a:num.
"******************************************************************************
    let l:bitCnt = 1
    let l:max = 2
    while a:num >= l:max
	let l:bitCnt += 1
	let l:max = l:max * 2
    endwhile
    return l:bitCnt
endfunction

"******************************************************************************
"* PURPOSE:
"   Return the power of a:x to the exponent a:y as a Number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:x Number.
"   a:y Exponent.
"* RETURN VALUES:
"   Number.
"******************************************************************************
if exists('*pow')
    function! ingo#math#PowNr( x, y )
	return float2nr(pow(a:x, a:y))
    endfunction
else
    function! ingo#math#PowNr( x, y )
	let l:r = a:x
	for l:i in range(a:y - 1)
	    let l:r = l:r * a:x
	endfor
	return l:r
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
