" surroundings/Lines.vim: Generic functions to surround whole lines with something.
"
" DEPENDENCIES:
"   - ingo/err.vim autoload script
"   - ingo/funcref.vim autoload script
"   - ingo/lines.vim autoload script
"
" Copyright: (C) 2013-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	007	10-Mar-2015	Handle custom exceptions / user aborts thrown by
"				a:Command.
"	006	12-May-2014	Enable aborting on error by returning the status
"				from surroundings#Lines#SurroundCommand() and
"				using ingo/err.vim.
"				CHG: Also allow transforming after the before-
"				and after-lines have been added. Restructure
"				a:Transformer argument into generic a:options,
"				with keys for the old
"				a:options.TransformerBefore and the new
"				a:options.TransformerAfter.
"				ENH: The Transformer(s) can now change the
"				amount of lines; the algorithm now deals with
"				that by calculating the offset.
"	005	17-Apr-2014	ENH: Allow to pass a Funcref as a:Command, too.
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

function! s:Transform( startLnum, endLnum, Transformer )
    try
	let l:originalLineNum = line('$')
	if type(a:Transformer) == type(function('tr'))
	    " Note: When going through call(), the Funcref is invoked once
	    " for each line, even when the referenced function is defined
	    " with the "range" attribute! Therefore, the transformer needs
	    " to be invoked directly. (Fortunately, we have no arguments to
	    " pass.)
	    execute a:startLnum . ',' . a:endLnum . 'call ' . ingo#funcref#ToString(a:Transformer) . '()'
	else
	    execute a:startLnum . ',' . a:endLnum . a:Transformer
	endif

	let l:offset = line('$') - l:originalLineNum
	return [1, l:offset]
    catch /^Vim\%((\a\+)\)\=:E16:/ " E16: Invalid range
	call ingo#err#Set(printf('Invalid last modified range: %d,%d', a:startLnum, a:endLnum))
	return [0, 0]
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return [0, 0]
    catch
	call ingo#err#SetCustomException(v:exception)
	return [0, 0]
    endtry
endfunction
function! surroundings#Lines#SurroundCommand( beforeLines, afterLines, options, count, startLnum, endLnum, Command )
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
"   a:options.TransformerBefore
"		    Hook to transform the range of lines before they have been
"		    surrounded.
"		    When not empty, is invoked as a Funcref / Ex command with
"		    the a:firstline, a:lastline range and no arguments. Should
"		    transform the range.
"   a:options.TransformerAfter
"		    Hook to transform the surrounded range of lines.
"   a:count         Range as <count> to check for default. When no range is
"		    passed in a command defined with -range=-1, the last
"		    modified range '[,'] is used instead of the following two
"		    arguments.
"   a:startLnum     Begin of the range to be surrounded.
"   a:endLnum       End of the range to be surrounded.
"   a:Command       A Funcref is passed the a:startLnum, a:endLnum and is
"		    expected to return a likewise List, which is then used. A
"		    non-empty String is executed as an Ex command, and the
"		    modified range is used instead of a:startLnum, a:endLnum.
"* RETURN VALUES:
"   1 in case of success; 0 if an error occurred. Use ingo#err#Get() to obtain
"   (and :echoerr) the message.
"******************************************************************************
    let l:TransformerBefore = get(a:options, 'TransformerBefore', '')
    let l:TransformerAfter = get(a:options, 'TransformerAfter', '')

    if a:count == -1
	" When no [range] is passed, -range=-1 defaults to <count> == -1.
	let [l:startLnum, l:endLnum] = [line("'["), line("']")]
    else
	let [l:startLnum, l:endLnum] = [a:startLnum, a:endLnum]
    endif
    if ! empty(a:Command)
	try
	    if type(a:Command) == type(function('tr'))
		let [l:startLnum, l:endLnum] = call(a:Command, [l:startLnum, l:endLnum])
	    else
		execute a:Command
		let [l:startLnum, l:endLnum] = [line("'["), line("']")]
	    endif
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#err#SetVimException()
	    return 0
	catch
	    call ingo#err#Set(v:exception)
	    return 0
	endtry
    endif

    if ! empty(l:TransformerBefore)
	let [l:isSuccess, l:offset] = s:Transform(l:startLnum, l:endLnum, l:TransformerBefore)
	if l:isSuccess
	    let l:endLnum += l:offset
	else
	    return 0
	endif
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
    let l:endLnum += len(l:beforeLines) + len(l:afterLines)

    if ! empty(l:TransformerAfter)
	let [l:isSuccess, l:offset] = s:Transform(l:startLnum, l:endLnum, l:TransformerAfter)
	if l:isSuccess
	    let l:endLnum += l:offset
	else
	    return 0
	endif
    endif

    " The entire block is the last changed text, not just the start marker that
    " was added last.
    call setpos("'[", [0, l:startLnum, 1, 0])
    call setpos("']", [0, l:endLnum, 1, 0])

    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
