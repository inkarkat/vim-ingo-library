" ingo/join.vim: Functions for joining lines in the buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2023 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:keeppatterns = matchstr(ingo#compat#commands#keeppatterns(), '^keeppatterns$')
function! ingo#join#Lines( lnum, isKeepSpace, separator )
"******************************************************************************
"* PURPOSE:
"   Join a:lnum with the next line, putting a:separator in between (and
"   optionally deleting any separating whitespace).
"* ASSUMPTIONS / PRECONDITIONS:
"   If a:isKeepSpace is false, the 'formatoptions' option may affect the join,
"   especially M, B, j.
"* EFFECTS / POSTCONDITIONS:
"   Joins lines.
"* INPUTS:
"   a:lnum  Line number of the first line to be joined.
"   a:isKeepSpace   Flag whether to keep whitespace (i.e. trailing in a:lnum,
"		    indent in a:lnum + 1) or remove it altogether. The joining
"		    itself does not add whitespace.
"   a:separator     String to be put in between the lines (also when one of them
"		    is completely empty).
"* RETURN VALUES:
"   None.
"******************************************************************************
    if a:lnum >= line('$')
	return 0
    endif

    let l:literalSeparator = (empty(a:separator)
    \   ? ''
    \   : (a:separator ==# "\<C-v>\<C-j>"
    \       ? nr2char(10)
    \       : ingo#regexp#EscapeLiteralReplacement(a:separator, '/')
    \   )
    \)

    if a:isKeepSpace
	execute s:keeppatterns a:lnum . 'substitute/^\(.*\)\n\(.*\)$/\1' . l:literalSeparator . '\2/'
    else
	let l:isFollowingOptionalWhitespaceLine = (getline(a:lnum + 1) =~# '^\s*$')
	execute a:lnum . 'normal! J'

	let l:changeJoiner = (empty(a:separator) ? '"_diw' : "\"_ciw\<C-v>\<C-@>\<Esc>")
	" The J command inserts one space in place of the <EOL> unless there is
	" trailing white space or the next line starts with a ')' or is empty.
	" The whitespace will be handed by "ciw", but we need a special case
	" for ')' and a following empty line.
	if ! search('\%#\s\|\s\%#', 'bcW', line('.'))
	    let l:changeJoiner = (empty(a:separator) ? '' : (l:isFollowingOptionalWhitespaceLine ? 'a' : 'i') . "\<C-v>\<C-@>\<Esc>")
	endif
	if ! empty(l:changeJoiner)
	    execute 'normal!' l:changeJoiner
	endif
	if ! empty(a:separator)
	    execute s:keeppatterns a:lnum . 'substitute/^\(.*\)\%x00\(.*\)$/\1' . l:literalSeparator . '\2/e'
	endif
    endif
    return 1
endfunction

function! ingo#join#Ranges( isKeepSpace, startLnum, endLnum, separator, ranges )
"******************************************************************************
"* PURPOSE:
"   Join each range of lines in a:ranges.
"* ASSUMPTIONS / PRECONDITIONS:
"   If a:isKeepSpace is false, the 'formatoptions' option may affect the join,
"   especially M, B, j.
"* EFFECTS / POSTCONDITIONS:
"   Joins lines.
"* INPUTS:
"   a:isKeepSpace   Flag whether to keep whitespace (i.e. trailing in a:lnum,
"		    indent in a:lnum + 1) or remove it altogether. The joining
"		    itself does not add whitespace.
"   a:startLnum     Ignored.
"   a:endLnum       Ignored.
"   a:separator     String to be put in between the lines (also when one of them
"		    is completely empty).
"   a:ranges        List of [startLnum, endLnum] pairs.
"* RETURN VALUES:
"   [ number of ranges, number of joined lines ]
"******************************************************************************
    if empty(a:ranges)
	return [0, 0]
    endif

    let l:joinCnt = 0
    let l:save_foldenable = &foldenable
    set nofoldenable
    try
	for [l:rangeStartLnum, l:rangeEndLnum] in reverse(a:ranges)
	    let l:cnt = l:rangeEndLnum - l:rangeStartLnum
	    for l:i in range(l:cnt)
		if ingo#join#Lines(l:rangeStartLnum, a:isKeepSpace, a:separator)
		    let l:joinCnt += 1
		endif
	    endfor
	endfor
    finally
	let &foldenable = l:save_foldenable
    endtry
    return [len(a:ranges), l:joinCnt]
endfunction

function! ingo#join#Range( isKeepSpace, startLnum, endLnum, separator )
"******************************************************************************
"* PURPOSE:
"   Join all lines in the a:startLnum, a:endLnum range.
"* ASSUMPTIONS / PRECONDITIONS:
"   If a:isKeepSpace is false, the 'formatoptions' option may affect the join,
"   especially M, B, j.
"* EFFECTS / POSTCONDITIONS:
"   Joins lines.
"* INPUTS:
"   a:isKeepSpace   Flag whether to keep whitespace (i.e. trailing in a:lnum,
"		    indent in a:lnum + 1) or remove it altogether. The joining
"		    itself does not add whitespace.
"   a:startLnum     First line of range.
"   a:endLnum       Last line of range.
"   a:separator     String to be put in between the lines (also when one of them
"		    is completely empty).
"* RETURN VALUES:
"   number of joined lines
"******************************************************************************
    return ingo#join#Ranges(a:isKeepSpace, 0, 0, a:separator, [[a:startLnum, a:endLnum]])[1]
endfunction

function! ingo#join#FoldedLines( isKeepSpace, startLnum, endLnum, separator )
"******************************************************************************
"* PURPOSE:
"   Join all folded lines.
"* ASSUMPTIONS / PRECONDITIONS:
"   If a:isKeepSpace is false, the 'formatoptions' option may affect the join,
"   especially M, B, j.
"* EFFECTS / POSTCONDITIONS:
"   Joins lines.
"* INPUTS:
"   a:isKeepSpace   Flag whether to keep whitespace (i.e. trailing in a:lnum,
"		    indent in a:lnum + 1) or remove it altogether. The joining
"		    itself does not add whitespace.
"   a:startLnum     First line number to be considered.
"   a:endLnum       last line number to be considered.
"   a:separator     String to be put in between the lines (also when one of them
"		    is completely empty).
"* RETURN VALUES:
"   [ number of folds, number of joined lines ]
"******************************************************************************
    let l:folds = ingo#folds#GetClosedFolds(a:startLnum, a:endLnum)
    return ingo#join#Ranges(a:isKeepSpace, a:startLnum, a:endLnum, a:separator, l:folds)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
