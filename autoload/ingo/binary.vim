" ingo/binary.vim: Functions for working with binary numbers.
"
" DEPENDENCIES:
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.029.001	28-Dec-2016	file creation

function! ingo#binary#FromNumber( number, ... )
"******************************************************************************
"* PURPOSE:
"   Turn the integer a:number into a (little-endian) List of boolean values.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number    Positive integer.
"   a:bitNum    Optional number of bits to use. If specified and a:number cannot
"		be represented by it, a exception is thrown. If a:bitNum is
"		negative, only the lower bits will be returned. If omitted, the
"		minimal amount of bits is used.
"* RETURN VALUES:
"   List of [b0, b1, b2, ...] boolean values; lowest bits come first.
"******************************************************************************
    let l:number = a:number
    let l:result = []
    let l:bitCnt = 0
    let l:bitMax = (a:0 ? ingo#compat#abs(a:1) : 0)

    while 1
	" Encode this little-endian.
	call add(l:result, l:number % 2)
	let l:number = l:number / 2
	let l:bitCnt += 1

	if l:bitMax && l:bitCnt == l:bitMax
	    if a:1 > 0 && l:number != 0
		throw printf('FromNumber: Cannot represent %d in %d bits', a:number, l:bitMax)
	    endif
	    break
	elseif ! a:0 && l:number == 0
	    break
	endif
    endwhile
    return l:result
endfunction
function! ingo#binary#ToNumber( bits )
"******************************************************************************
"* PURPOSE:
"   Turn the (little-endian) List of boolean values into a number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:bits  List of [b0, b1, b2, ...] boolean values; lowest bits come first.
"* RETURN VALUES:
"   Positive integer represented by a:bits.
"******************************************************************************
    let l:number = 0
    let l:factor = 1
    while ! empty(a:bits)
	let l:number += l:factor * remove(a:bits, 0)
	let l:factor = l:factor * 2
    endwhile
    return l:number
endfunction

function! ingo#binary#BitsRequired( number )
"******************************************************************************
"* PURPOSE:
"   Determine the number of bits required to represent a:number.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:number   Positive integer.
"* RETURN VALUES:
"   Number of bits required to represent numbers between 0 and a:number.
"******************************************************************************
    let l:bitCnt = 1
    let l:max = 2
    while a:number >= l:max
	let l:bitCnt += 1
	let l:max = l:max * 2
    endwhile
    return l:bitCnt
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
