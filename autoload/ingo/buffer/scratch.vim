" ingo/buffer/scratch.vim: Functions for creating scratch buffers.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/escape/file.vim autoload script
"   - ingo/fs/path.vim autoload script
"
" Copyright: (C) 2009-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#buffer#scratch#NextBracketedFilename( filespec, template )
"******************************************************************************
"* PURPOSE:
"   Based on the current format of a:filespec, return a successor according to
"   a:template. The sequence is:
"	1. name [template]
"	2. name [template1]
"	3. name [template2]
"	4. ...
"   The "name" part may be omitted.
"   This does not check for actual occurrences in loaded buffers, etc.; it just
"   performs text manipulation!
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filename on which to base the result.
"   a:template  Identifier to be used inside the bracketed counted addendum.
"* RETURN VALUES:
"   filename
"******************************************************************************
    let l:templateExpr = '\V\C'. escape(a:template, '\') . '\m'
    if a:filespec !~# '\%(^\| \)\[' . l:templateExpr . ' \?\d*\]$'
	return a:filespec . (empty(a:filespec) ? '' : ' ') . '['. a:template . ']'
    elseif a:filespec !~# '\%(^\| \)\[' . l:templateExpr . ' \?\d\+\]$'
	return substitute(a:filespec, '\]$', '1]', '')
    else
	let l:number = matchstr(a:filespec, '\%(^\| \)\[' . l:templateExpr . ' \?\zs\d\+\ze\]$')
	return substitute(a:filespec, '\d\+\]$', (l:number + 1) . ']', '')
    endif
endfunction
function! ingo#buffer#scratch#NextFilename( filespec )
    return ingo#buffer#scratch#NextBracketedFilename(a:filespec, 'Scratch')
endfunction
function! s:Bufnr( dirspec, filename, isFile )
    if empty(a:dirspec) && ! a:isFile
	" This scratch buffer does not behave like a file and is not tethered to
	" a particular directory; there should be only one scratch buffer with
	" this name in the Vim session.
	" Do a partial search for the buffer name matching any file name in any
	" directory.
	return bufnr(ingo#escape#file#bufnameescape(a:filename, 1, 0))
    else
	return bufnr(
	\   ingo#escape#file#bufnameescape(
	\	fnamemodify(
	\	    ingo#fs#path#Combine(a:dirspec, a:filename),
	\	    '%:p'
	\	)
	\   )
	\)
    endif
endfunction
function! ingo#buffer#scratch#GetUnusedBracketedFilename( dirspec, baseFilename, isFile, template )
"******************************************************************************
"* PURPOSE:
"   Determine the next available bracketed filename that does not exist as a Vim
"   buffer yet.
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:dirspec   Working directory for the buffer. Pass empty string to maintain
"		the current CWD as-is.
"   a:baseFilename  Filename to base the bracketed filename on; can be empty if
"		    you don't want any prefix before the brackets.
"   a:isFile    Flag whether the buffer should behave like a file (i.e. adapt to
"		changes in the global CWD), or not. If false and a:dirspec is
"		empty, there will be only one buffer with the same filename,
"		regardless of the buffer's directory path.
"   a:template  Identifier to be used inside the bracketed counted addendum.
"* RETURN VALUES:
"   filename
"******************************************************************************
    let l:bracketedFilename = a:baseFilename
    while 1
	let l:bracketedFilename = ingo#buffer#scratch#NextBracketedFilename(l:bracketedFilename, a:template)
	if s:Bufnr(a:dirspec, l:bracketedFilename, a:isFile) == -1
	    return l:bracketedFilename
	endif
    endwhile
endfunction
function! s:ChangeDir( dirspec )
    if empty( a:dirspec )
	return
    endif
    execute 'lchdir' ingo#compat#fnameescape(a:dirspec)
endfunction
function! s:BufType( scratchIsFile )
    return (a:scratchIsFile ? 'nowrite' : 'nofile')
endfunction
function! ingo#buffer#scratch#Create( scratchDirspec, scratchFilename, scratchIsFile, scratchCommand, windowOpenCommand )
"*******************************************************************************
"* PURPOSE:
"   Create (or re-use an existing) scratch buffer (i.e. doesn't correspond to a
"   file on disk, but can be saved as such).
"   To keep the scratch buffer (and create a new scratch buffer on the next
"   invocation), rename the current scratch buffer via ':file <newname>', or
"   make it a normal buffer via ':setl buftype='.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates or opens scratch buffer and loads it in a window (as specified by
"   a:windowOpenCommand) and activates that window.
"* INPUTS:
"   a:scratchDirspec	Local working directory for the scratch buffer
"			(important for :! scratch commands). Pass empty string
"			to maintain the current CWD as-is. Pass '.' to maintain
"			the CWD but also fix it via :lcd.
"			(Attention: ':set autochdir' will reset any CWD once the
"			current window is left!) Pass the getcwd() output if
"			maintaining the current CWD is important for
"			a:scratchCommand.
"   a:scratchFilename	The name for the scratch buffer, so it can be saved via
"			either :w! or :w <newname>.
"   a:scratchIsFile	Flag whether the scratch buffer should behave like a
"			file (i.e. adapt to changes in the global CWD), or not.
"			If false and a:scratchDirspec is empty, there will be
"			only one scratch buffer with the same a:scratchFilename,
"			regardless of the scratch buffer's directory path.
"   a:scratchCommand	Ex command(s) to populate the scratch buffer, e.g.
"			":1read myfile". Use :1read so that the first empty line
"			will be kept (it is deleted automatically), and there
"			will be no trailing empty line.
"			Pass empty string if you want to populate the scratch
"			buffer yourself.
"			Pass a List of lines to set the scratch buffer contents
"			directly to the lines.
"   a:windowOpenCommand	Ex command to open the scratch window, e.g. :vnew or
"			:topleft new.
"* RETURN VALUES:
"   Indicator whether the scratch buffer has been opened:
"   0	Failed to open scratch buffer.
"   1	Already in scratch buffer window.
"   2	Jumped to open scratch buffer window.
"   3	Loaded existing scratch buffer in new window.
"   4	Created scratch buffer in new window.
"   Note: To handle errors caused by a:scratchCommand, you need to put this
"   method call into a try..catch block and :close the scratch buffer when an
"   exception is thrown.
"*******************************************************************************
    let l:currentWinNr = winnr()
    let l:status = 0

    let l:scratchBufnr = s:Bufnr(a:scratchDirspec, a:scratchFilename, a:scratchIsFile)
    let l:scratchWinnr = bufwinnr(l:scratchBufnr)
"****D echomsg '**** bufnr=' . l:scratchBufnr 'winnr=' . l:scratchWinnr
    if l:scratchWinnr == -1
	if l:scratchBufnr == -1
	    execute a:windowOpenCommand
	    " Note: The directory must already be changed here so that the :file
	    " command can set the correct buffer filespec.
	    call s:ChangeDir(a:scratchDirspec)
	    execute 'silent keepalt file' ingo#compat#fnameescape(a:scratchFilename)
	    let l:status = 4
	elseif getbufvar(l:scratchBufnr, '&buftype') ==# s:BufType(a:scratchIsFile)
	    execute a:windowOpenCommand
	    execute l:scratchBufnr . 'buffer'
	    let l:status = 3
	else
	    " A buffer with the scratch filespec is already loaded, but it
	    " contains an existing file, not a scratch file. As we don't want to
	    " jump to this existing file, try again with the next scratch
	    " filename.
	    return ingo#buffer#scratch#Create(a:scratchDirspec, ingo#buffer#scratch#NextFilename(a:scratchFilename), a:scratchIsFile, a:scratchCommand, a:windowOpenCommand)
	endif
    else
	if getbufvar(l:scratchBufnr, '&buftype') !=# s:BufType(a:scratchIsFile)
	    " A window with the scratch filespec is already visible, but its
	    " buffer contains an existing file, not a scratch file. As we don't
	    " want to jump to this existing file, try again with the next
	    " scratch filename.
	    return ingo#buffer#scratch#Create(a:scratchDirspec, ingo#buffer#scratch#NextFilename(a:scratchFilename), a:scratchIsFile, a:scratchCommand, a:windowOpenCommand)
	elseif l:scratchWinnr == l:currentWinNr
	    let l:status = 1
	else
	    execute l:scratchWinnr . 'wincmd w'
	    let l:status = 2
	endif
    endif

    call s:ChangeDir(a:scratchDirspec)
    setlocal noreadonly
    silent %delete _
    " Note: ':silent' to suppress the "--No lines in buffer--" message.

    if ! empty(a:scratchCommand)
	if type(a:scratchCommand) == type([])
	    call setline(1, a:scratchCommand)
	    call cursor(1, 1)
	    call setpos("'[", [0, 1, 1, 0])
	    call setpos("']", [0, line('$'), 1, 0])
	else
	    execute a:scratchCommand
	    " ^ Keeps the existing line at the top of the buffer, if :1{cmd} is used.
	    " v Deletes it.
	    if empty(getline(1))
		let l:save_cursor = getpos('.')
		    silent 1delete _    " Note: ':silent' to suppress deletion message if ':set report=0'.
		call cursor(l:save_cursor[1] - 1, l:save_cursor[2])
	    endif
	endif

	setlocal readonly
    endif

    call ingo#buffer#scratch#SetLocal(a:scratchIsFile)
    return l:status
endfunction
function! ingo#buffer#scratch#SetLocal( isFile )
    execute 'setlocal buftype=' . s:BufType(a:isFile)
    setlocal bufhidden=wipe nobuflisted noswapfile
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
