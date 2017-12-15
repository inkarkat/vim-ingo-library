" ingo/regexp/split.vim: Functions to split a regular expression.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#split#TopLevelBranches( pattern )
"******************************************************************************
"* PURPOSE:
"   Split a:pattern on "\|" - separated branches, keeping nested \(...\|...\)
"   branches inside (non-)capture groups together. If the complete a:pattern in
"   wrapped in a group, it is treated as one toplevel branch, too.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax (...|...). If you may have
"   this, convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   List of regular expression branch fragments.
"******************************************************************************
    let l:rawBranches = split(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\|', 1)
    let l:openGroupCnt = 0
    let l:branches = []

    let l:currentBranch = ''
    while ! empty(l:rawBranches)
	let l:currentBranch = remove(l:rawBranches, 0)
	let l:currentOpenGroupCnt = l:openGroupCnt

	let l:count = 1
	while 1
	    let l:match = matchstr(l:currentBranch, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(%\?(\|)\)', 0, l:count)
	    if empty(l:match)
		break
	    elseif l:match == '\)'
		let l:openGroupCnt = max([0, l:openGroupCnt - 1])
	    else
		let l:openGroupCnt += 1
	    endif
	    let l:count += 1
	endwhile

	if l:currentOpenGroupCnt == 0
	    call add(l:branches, l:currentBranch)
	else
	    if empty(l:branches)
		let l:branches = ['']
	    endif
	    let l:branches[-1] .= '\|' . l:currentBranch
	endif
    endwhile

    return l:branches
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
