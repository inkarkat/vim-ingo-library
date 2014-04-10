" ingo/buffer/temprange.vim: Functions to execute stuff in a temp area in the same buffer.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	09-Apr-2014	file creation from visualrepeat.vim

function! ingo#buffer#temprange#Execute( lines, command )
"******************************************************************************
"* PURPOSE:
"   Invoke an Ex command on temporarily added lines in the current buffer.
"   Some transformations need to operate in the context of the current buffer
"   (so that the buffer settings apply), but should not directly modify the
"   buffer. This functions temporarily inserts the lines at the end of the
"   buffer, applies the command from the beginning of those lines, then removes
"   the temporary range and returns it.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lines     List of lines (or String of a single line) to be temporarily
"		processed by a:command.
"   a:command	Ex command to be invoked. The cursor will be positioned on the
"		first column of the first line of a:lines. The command should
"		ensure that no lines above that line are modified! In
"		particular, the number of existing lines must not be changed (or
"		the line capture will return the wrong lines).
"* RETURN VALUES:
"   a:lines, as modified by a:command.
"******************************************************************************
    " Save the view; the command execution / :delete of the temporary
    " range later modifies the cursor position.
    let l:save_view = winsaveview()
    let l:finalLnum = line('$')
    if exists('*undotree')
	let l:undoSequenceNumber = undotree().seq_cur
    else
	" Cannot directly get the current undo sequence number from :undolist;
	" must create a new undo point, and later undo beyond that.
	call setline('$', getline('$'))
	redir => l:undolistOutput
	    silent! undolist
	redir END
	let l:undoSequenceNumber = str2nr(split(l:undolistOutput, "\n")[-1])
    endif

    let l:tempRange = (l:finalLnum + 1) . ',$'
    call append(l:finalLnum, a:lines)

    " The cursor is set to the first column of the first temp line.
    call cursor(l:finalLnum + 1, 1)
    try
	execute a:command
	let l:result = getline(l:finalLnum + 1, '$')
	return l:result
    finally
	try
	    " Using :undo to roll back the append and command is safer, because
	    " any potential modification outside the temporary range is also
	    " eliminated. And this doesn't pollute the undo history. Only
	    " explicitly delete the temporary range as a fallback.
	    if l:undoSequenceNumber <= 0 | throw CannotUndo | endif
	    silent execute 'undo' l:undoSequenceNumber
	    if ! exists('*undotree')
		silent undo " Need one more undo here.
	    endif
	catch /^CannotUndo$\|^Vim\%((\a\+)\)\=:E/
	    silent! execute l:tempRange . 'delete _'
	endtry

	call winrestview(l:save_view)
    endtry
endfunction
function! ingo#buffer#temprange#Call( lines, Funcref, arguments )
    return ingo#buffer#temprange#Execute(a:lines, 'call call(' . string(a:Funcref) . ',' . string(a:arguments) . ')')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
