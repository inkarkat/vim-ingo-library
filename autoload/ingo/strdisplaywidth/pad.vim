" ingo/strdisplaywidth/pad.vim: Functions for padding a string to certain display width.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/tabstops.vim autoload script
"
" Copyright: (C) 2013-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.003	15-May-2017	CHG: Rename ill-named
"				ingo#strdisplaywidth#pad#Middle() to
"				ingo#strdisplaywidth#pad#Center()
"				Add "real" ingo#strdisplaywidth#pad#Middle()
"				that inserts the padding in the middle of the
"				string / between the two passed string parts.
"   1.026.002	11-Aug-2016	Add ingo#strdisplaywidth#pad#Middle().
"   1.009.001	20-Jun-2013	file creation

function! ingo#strdisplaywidth#pad#Width( text, width, ... )
"******************************************************************************
"* PURPOSE:
"   Determine the amount of padding for a:text so that the overall display width
"   is at least a:width.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be padded.
"   a:width Desired display width.
"   a:tabstop	    Optional tabstop value; defaults to the buffer's 'tabstop'
"		    value.
"   a:startColumn   Optional column at which the text is to be rendered (default
"		    1).
"* RETURN VALUES:
"   Amount of display cells of padding for a:text, or 0 if its width is already
"   (more than) enough.
"******************************************************************************
    let l:existingWidth = call('ingo#compat#strdisplaywidth', [a:text] + a:000)
    return max([0, a:width - l:existingWidth])
endfunction
function! ingo#strdisplaywidth#pad#Left( text, width, ... )
"******************************************************************************
"* PURPOSE:
"   Add padding to the right of a:text so that the overall display width is at
"   least a:width.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be padded.
"   a:width Desired display width.
"   a:tabstop	    Optional tabstop value; defaults to the buffer's 'tabstop'
"		    value.
"   a:startColumn   Optional column at which the text is to be rendered (default
"		    1).
"* RETURN VALUES:
"   Padded text, or original text if its width is already (more than) enough.
"******************************************************************************
    " Any contained <Tab> characters would change their width when the padding
    " is prepended. Therefore, render them first into spaces.
    let l:renderedText = call('ingo#tabstops#Render', [a:text] + a:000)
    return repeat(' ', ingo#strdisplaywidth#pad#Width(l:renderedText, a:width)) . l:renderedText
endfunction
function! ingo#strdisplaywidth#pad#Right( text, width, ... )
"******************************************************************************
"* PURPOSE:
"   Add padding to the right of a:text so that the overall display width is at
"   least a:width.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be padded.
"   a:width Desired display width.
"   a:tabstop	    Optional tabstop value; defaults to the buffer's 'tabstop'
"		    value.
"   a:startColumn   Optional column at which the text is to be rendered (default
"		    1).
"* RETURN VALUES:
"   Padded text, or original text if its width is already (more than) enough.
"******************************************************************************
    return a:text . repeat(' ', call('ingo#strdisplaywidth#pad#Width', [a:text, a:width] + a:000))
endfunction
function! ingo#strdisplaywidth#pad#Center( text, width, ... )
"******************************************************************************
"* PURPOSE:
"   Add padding to the left and right of a:text so that the overall display
"   width is at least a:width.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be padded.
"   a:width Desired display width.
"   a:tabstop	    Optional tabstop value; defaults to the buffer's 'tabstop'
"		    value.
"   a:startColumn   Optional column at which the text is to be rendered (default
"		    1).
"* RETURN VALUES:
"   Padded text, or original text if its width is already (more than) enough.
"******************************************************************************
    let l:renderedText = call('ingo#tabstops#Render', [a:text] + a:000)
    let l:existingWidth = call('ingo#compat#strdisplaywidth', [l:renderedText] + a:000)
    let l:pad = a:width - l:existingWidth
    if l:pad <= 0
	return l:renderedText
    endif

    let l:leftPad = l:pad / 2
    let l:rightPad = l:pad - l:leftPad
    return repeat(' ', l:leftPad) . l:renderedText . repeat(' ', l:rightPad)
endfunction
function! ingo#strdisplaywidth#pad#Middle( text, width, ... )
"******************************************************************************
"* PURPOSE:
"   Add padding in the middle of a:text / between [a:left, a:right] so that the
"   overall display width is at least a:width.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be padded, or List of [a:left, a:right] text parts.
"   a:width Desired display width.
"   a:tabstop	    Optional tabstop value; defaults to the buffer's 'tabstop'
"		    value.
"   a:startColumn   Optional column at which the text is to be rendered (default
"		    1).
"* RETURN VALUES:
"   Padded text, or original text if its width is already (more than) enough.
"******************************************************************************
    if type(a:text) == type([])
	let [l:left, l:right] = map(copy(a:text), "call('ingo#tabstops#Render', [v:val] + a:000)")
	let l:renderedText = l:left . l:right
    else
	let l:renderedText = call('ingo#tabstops#Render', [a:text] + a:000)
	let [l:left, l:right] = ingo#strdisplaywidth#CutLeft(l:renderedText, ingo#compat#strdisplaywidth(l:renderedText) / 2)
    endif
    let l:existingWidth = call('ingo#compat#strdisplaywidth', [l:renderedText] + a:000)

    let l:pad = a:width - l:existingWidth
    if l:pad <= 0
	return l:renderedText
    endif

    return l:left . repeat(' ', ingo#strdisplaywidth#pad#Width(l:renderedText, a:width)) . l:right
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
