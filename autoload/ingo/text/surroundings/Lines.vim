" surroundings/Lines.vim: Generic functions to surround whole lines with something.
"
" DEPENDENCIES:
"   - ingo/funcref.vim autoload script
"   - ingo/lines.vim autoload script
"   - ingo/msg.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	06-Nov-2013	FIX: Uninitialized l:beforeLines l:afterLines.
"	003	05-Nov-2013	ENH: Support dynamic a:beforeLines and
"				a:afterLines.
"				Do not invoke the a:Transformer once per line if
"				the underlying function has been defined with
"				the "range" attribute.
"	002	21-Apr-2013	Change -range=-1 default check to use <count>
"				(now passed in separately), which maintains the
"				actual -1 default, and therefore also delivers
"				correct results when on line 1.
"				Make the error message on invalid last modified
"				range more telling than "E16: Invalid range:
"				3,7call call(a:Transformer, [])"
"	001	04-Apr-2013	file creation from ftplugin/mail_ingomappings.vim

function! surroundings#Lines#SurroundCommand( beforeLines, afterLines, Transformer, count, startLnum, endLnum, command )
"******************************************************************************
"* PURPOSE:
"   Surround the lines between a:startLnum and a:endLnum with added
"   a:beforeLines and a:afterLines and/or transform them via a:Transformer.
"* ASSUMPTIONS / PRECONDITIONS:
"   Current buffer is modifiable.
"* EFFECTS / POSTCONDITIONS:
"   Changes the lines.
"* INPUTS:
"   a:beforeLines   List of text lines to be prepended before a:startLnum, or a
"		    Funcref returning such.
"   a:afterLines    List of text lines to be appended after a:endLnum, or a
"		    Funcref returning such.
"   a:Transformer   When not empty, is invoked as a Funcref / Ex command with
"		    the a:startLnum,a:endLnum range. Should transform the range.
"   a:count         Range as <count> to check for default. When no range is
"		    passed in a command defined with -range=-1, the last
"		    modified range '[,'] is used instead of the following two
"		    arguments.
"   a:startLnum     Begin of the range to be surrounded.
"   a:endLnum       End of the range to be surrounded.
"   a:command       When not empty, is executed as an Ex command, and the
"		    modified range is used instead of a:startLnum,a:endLnum.
"* RETURN VALUES:
"   None.
"******************************************************************************
    if empty(a:command)
	if a:count == -1
	    " When no [range] is passed, -range=-1 defaults to <count> == -1.
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
		" Note: When going through call(), the Funcref is invoked once
		" for each line, even when the referenced function is defined
		" with the "range" attribute! Therefore, the transformer needs
		" to be invoked directly. (Fortunately, we have to arguments to
		" pass.)
		execute l:startLnum . ',' . l:endLnum . 'call ' . ingo#funcref#ToString(a:Transformer) . '()'
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

    let l:beforeLines = []
    let l:afterLines = []
    if ! empty(a:afterLines)
	let l:afterLines = ingo#actions#ValueOrFunc(a:afterLines)
	silent call ingo#lines#PutWrapper(l:endLnum, 'put', l:afterLines)
    endif
    if ! empty(a:beforeLines)
	let l:beforeLines = ingo#actions#ValueOrFunc(a:beforeLines)
	silent call ingo#lines#PutWrapper(l:startLnum, 'put!', l:beforeLines)
    endif

    " The entire block is the last changed text, not just the start marker that
    " was added last.
    call setpos("'[", [0, l:startLnum, 1, 0])
    call setpos("']", [0, l:endLnum + len(l:beforeLines) + len(l:afterLines), 1, 0])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
