" ingomotion.vim: Custom motions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	01-Aug-2012	Avoid cursor movement when there's no change /
"				spell checking is not enabled by trying a jump
"				before moving the cursor to the beginning / end
"				of the buffer.
"	001	01-Aug-2012	file creation from UniversalIteratorMapping.vim

" In diff mode, the granularity of changes is _per line_. The ']c' command
" doesn't wrap around the file.
" To go to the first change (even when it's on the first line of the buffer), go
" to line 1, then next change, then previous change.
function! s:TryGotoChange()
    let l:currentPosition = getpos('.')
    silent! normal! [c
    if getpos('.') == l:currentPosition
	silent! normal! ]c
	if getpos('.') == l:currentPosition
	    return 0
	endif
    endif

    return 1
endfunction
function! ingomotion#GotoFirstChange( count )
    " Try to locate any change before moving the cursor.
    if ! s:TryGotoChange()
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	return
    endif

    normal! gg]c
    silent! normal! [c

    if a:count > 1
	execute 'normal!' (v:count - 1) . ']c'
    endif
endfunction
function! ingomotion#GotoLastChange( count )
    " Try to locate any change before moving the cursor.
    if ! s:TryGotoChange()
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	return
    endif

    normal! G[c
    silent! normal! ]c

    if a:count > 1
	execute 'normal!' (v:count - 1) . '[c'
    endif
endfunction


" In spell mode, the granularity of spell errors is _per word_. The ']s' command
" observes 'wrapscan' and can thus wrap around the file.
" To go to the first spell error, temporarily turn off 'wrapscan' (this also
" avoids any wrap message), goto first line, first column, then next
" spell error, then previous spell error (there is only one if the buffer starts
" with a misspelling).
" To go to the last spell error, goto last line, last column, then previous
" spell error. (If the last word has a spell error, that'll jump to the
" beginning of the last word.)
" When typed, ']s' et al. open the fold at the search result, but inside a
" mapping or :normal this must be done explicitly via 'zv'.
function! ingomotion#GotoFirstMisspelling( count )
    let l:save_wrapscan = &wrapscan
    try
	" Do a jump to any misspelling first to force the "E756: Spell checking
	" is not enabled" error before moving the cursor.
	set wrapscan
	silent normal! ]s

	set nowrapscan
	normal! gg0]s
	silent! normal! [s
    finally
	let &wrapscan = l:save_wrapscan
    endtry

    if a:count > 1
	execute 'normal!' (v:count - 1) . ']s'
    endif

    normal! zv
endfunction
function! ingomotion#GotoLastMisspelling( count )
    let l:save_wrapscan = &wrapscan
    try
	" Do a jump to any misspelling first to force the "E756: Spell checking
	" is not enabled" error before moving the cursor.
	set wrapscan
	silent normal! ]s

	set nowrapscan
	normal! G$[s
    finally
	let &wrapscan = l:save_wrapscan
    endtry

    if a:count > 1
	execute 'normal!' (v:count - 1) . '[s'
    endif

    normal! zv
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
