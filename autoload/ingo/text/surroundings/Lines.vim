" surroundings/Lines.vim: Generic functions to surround whole lines with something.
"
" DEPENDENCIES:
"   - ingo/lines.vim autoload script
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	21-Apr-2013	Change bias of -range=-1 default check to prefer
"				current line (when on line 1) instead the
"				last modified range default.
"				Make the error message on invalid last modified
"				range more telling than "E16: Invalid range:
"				3,7call call(a:Transformer, [])"
"	001	04-Apr-2013	file creation from ftplugin/mail_ingomappings.vim

function! surroundings#Lines#SurroundCommand( beforeLines, afterLines, Transformer, startLnum, endLnum, command )
"******************************************************************************
"* PURPOSE:
"   Surround the lines between a:startLnum and a:endLnum with added
"   a:beforeLines and a:afterLines and/or transform them via a:Transformer.
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the lines.
"* INPUTS:
"   a:beforeLines   List of text lines to be prepended before a:startLnum.
"   a:afterLines    List of text lines to be appended after a:endLnum.
"   a:Transformer   When not empty, is invoked as a Funcref / Ex command with
"		    the a:startLnum,a:endLnum range. Should transform the range.
"   a:startLnum     Begin of the range to be surrounded.
"   a:endLnum       End of the range to be surrounded. When no range is passed
"		    in a command defined with -range=-1, the last modified range
"		    '[,'] is used instead.
"   a:command       When not empty, is executed as an Ex command, and the
"		    modified range is used instead of a:startLnum,a:endLnum.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if empty(a:command)
	if a:endLnum == 1 && line('.') != 1
	    " When no [range] is passed, -range=-1 defaults to <line2> == 1.
	    let [l:startLnum, l:endLnum] = [line("'["), line("']")]
	else
	    let [l:startLnum, l:endLnum] = [a:startLnum, a:endLnum]
	endif
    else
	try
	    execute a:command
	    let [l:startLnum, l:endLnum] = [line("'["), line("']")]
	catch /^Vim\%((\a\+)\)\=:E/
	    call ingo#msg#VimExceptionMsg()
	    return
	endtry
    endif

    if ! empty(a:Transformer)
	try
	    if type(a:Transformer) == type(function('tr'))
		execute l:startLnum . ',' . l:endLnum . 'call call(a:Transformer, [])'
	    else
		execute l:startLnum . ',' . l:endLnum . a:Transformer
	    endif
	catch /^Vim\%((\a\+)\)\=:E16/ " E16: Invalid range
	    call ingo#msg#ErrorMsg(printf('Invalid last modified range: %d,%d', l:startLnum, l:endLnum))
	    return
	catch /^Vim\%((\a\+)\)\=:E/
	    call ingo#msg#VimExceptionMsg()
	    return
	catch
	    call ingo#msg#ErrorMsg(v:exception)
	    return
	endtry
    endif

    if ! empty(a:afterLines)
	silent call ingo#lines#PutWrapper(l:endLnum, 'put', a:afterLines)
    endif
    if ! empty(a:beforeLines)
	silent call ingo#lines#PutWrapper(l:startLnum, 'put!', a:beforeLines)
    endif

    " The entire block is the last changed text, not just the start marker that
    " was added last.
    call setpos("'[", [0, l:startLnum, 1, 0])
    call setpos("']", [0, l:endLnum + len(a:beforeLines) + len(a:afterLines), 1, 0])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
