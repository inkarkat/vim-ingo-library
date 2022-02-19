" ingo/query/get.vim: Functions for querying simple data types from the user.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#query#get#Number( maxNum, ... )
"******************************************************************************
"* PURPOSE:
"   Query a number from the user. In contrast to |getchar()|, this allows for
"   multiple digits. In contrast to |input()|, the entry need not necessarily be
"   concluded with <Enter>, saving one keystroke.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   :echo's the typed number.
"* INPUTS:
"   a:maxNum    Maximum number to be input.
"   a:defaultNum    Number when the query is acknowledged with <Enter> without
"		    entering any digit. Default is -1.
"* RETURN VALUES:
"   Either the entered number, a:defaultNum when only <Enter> is pressed, or -1
"   when an invalid (i.e. non-digit) number was entered.
"******************************************************************************
    let l:nr = 0
    let l:leadingZeroCnt = 0
    while 1
	let l:char = nr2char(getchar())

	if l:char ==# "\<CR>"
	    return (l:nr == 0 ? (a:0 ? a:1 : -1) : l:nr)
	elseif l:char !~# '\d'
	    return -1
	endif
	echon l:char

	if l:char ==# '0' && l:nr == 0
	    let l:leadingZeroCnt += 1
	    if l:leadingZeroCnt >= len(a:maxNum)
		return 0
	    endif
	else
	    let l:nr = 10 * l:nr + str2nr(l:char)
	    if a:maxNum < 10 * l:nr || l:leadingZeroCnt + len(l:nr) >= len(a:maxNum)
		return l:nr
	    endif
	endif
    endwhile
endfunction

function! s:GetChar()
    " TODO: Handle digraphs via <C-K>.
    let l:char = getchar()
    if type(l:char) == type(0)
	let l:char = nr2char(l:char)
    endif
    return l:char
endfunction
function! ingo#query#get#Char( ... )
"******************************************************************************
"* PURPOSE:
"   Query a character from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.isBeepOnInvalid   Flag whether to beep on invalid pattern (but not
"				when aborting with <Esc>). Default on.
"   a:options.validExpr         Pattern for valid characters. Aborting with
"				<Esc> is always possible, but if you add \e, it
"				will be returned as ^[.
"   a:options.invalidExpr       Pattern for invalid characters. Takes precedence
"				over a:options.validExpr.
"* RETURN VALUES:
"   Either the valid character, or an empty string when aborted or invalid
"   character.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isBeepOnInvalid = get(l:options, 'isBeepOnInvalid', 1)
    let l:validExpr = get(l:options, 'validExpr', '')
    let l:invalidExpr = get(l:options, 'invalidExpr', '')

    let l:char = s:GetChar()
    if l:char ==# "\<Esc>" && (empty(l:validExpr) || l:char !~ l:validExpr)
	return ''
    elseif (! empty(l:validExpr) && l:char !~ l:validExpr) ||
    \   (! empty(l:invalidExpr) && l:char =~ l:invalidExpr)
	if l:isBeepOnInvalid
	    execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	endif
	return ''
    endif

    return l:char
endfunction
function! ingo#query#get#ValidChar( ... )
"******************************************************************************
"* PURPOSE:
"   Query a character from the user until a valid one has been pressed (or
"   aborted with <Esc>).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.isBeepOnInvalid   Flag whether to beep on invalid pattern (but not
"				when aborting with <Esc>). Default on.
"   a:options.validExpr         Pattern for valid characters. Aborting with
"				<Esc> is always possible, but if you add \e, it
"				will be returned as ^[.
"   a:options.invalidExpr       Pattern for invalid characters. Takes precedence
"				over a:options.validExpr.
"* RETURN VALUES:
"   Either the valid character, or an empty string when aborted.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isBeepOnInvalid = get(l:options, 'isBeepOnInvalid', 1)
    let l:validExpr = get(l:options, 'validExpr', '')
    let l:invalidExpr = get(l:options, 'invalidExpr', '')

    while 1
	let l:char = s:GetChar()

	if l:char ==# "\<Esc>" && (empty(l:validExpr) || l:char !~ l:validExpr)
	    return ''
	elseif (! empty(l:validExpr) && l:char !~ l:validExpr) ||
	\   (! empty(l:invalidExpr) && l:char =~ l:invalidExpr)
	    if l:isBeepOnInvalid
		execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	    endif
	else
	    break
	endif
    endwhile

    return l:char
endfunction

function! ingo#query#get#Register( ... )
"******************************************************************************
"* PURPOSE:
"   Query a register from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:errorRegister     Register name to be returned when aborted or invalid
"			register. Defaults to the empty string. Use '\' to yield
"			an empty string (from getreg()) when passing the
"			function's results directly to getreg().
"   a:invalidRegisterExpr   Optional pattern for invalid registers.
"* RETURN VALUES:
"   Either the register, or an a:errorRegister when aborted or invalid register.
"******************************************************************************
    let l:errorRegister = (a:0 ? a:1 : '')
    try
	let l:register = ingo#query#get#Char({'validExpr': ingo#register#All(), 'invalidExpr': (a:0 >= 2 ? a:2 : '')})
	return (empty(l:register) ? l:errorRegister : l:register)
    catch /^Vim\%((\a\+)\)\=:E523:/ " E523: Not allowed here
	return l:errorRegister
    endtry
endfunction
function! ingo#query#get#WritableRegister( ... )
"******************************************************************************
"* PURPOSE:
"   Query a register that can be written to from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:errorRegister     Register name to be returned when aborted or invalid
"			register. Defaults to the empty string. Use '\' to yield
"			an empty string (from getreg()) when passing the
"			function's results directly to getreg().
"   a:invalidRegisterExpr   Optional pattern for invalid registers.
"* RETURN VALUES:
"   Either the writable register, or an a:errorRegister when aborted or invalid
"   register.
"******************************************************************************
    let l:errorRegister = (a:0 ? a:1 : '')
    try
	let l:register = ingo#query#get#Char({'validExpr': ingo#register#Writable(), 'invalidExpr': (a:0 >= 2 ? a:2 : '')})
	return (empty(l:register) ? l:errorRegister : l:register)
    catch /^Vim\%((\a\+)\)\=:E523:/ " E523: Not allowed here
	return l:errorRegister
    endtry
endfunction

function! ingo#query#get#Mark( ... )
"******************************************************************************
"* PURPOSE:
"   Query a mark from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:invalidMarkExpr   Optional pattern for invalid marks. Or pass 1 when you
"			want to use the mark for setting, and filter out all
"			read-only marks.
"* RETURN VALUES:
"   Either the mark, or empty string when aborted or invalid register.
"******************************************************************************
    try
	return ingo#query#get#Char({
	\   'validExpr': '[a-zA-Z0-9''`"[\]<>^.(){}]',
	\   'invalidExpr': (a:0 ? (a:1 is# 1 ? '[0-9^.(){}]' : a:1) : '')
	\})
    catch /^Vim\%((\a\+)\)\=:E523:/ " E523: Not allowed here
	return ''
    endtry
endfunction


if ! exists('g:IngoLibrary_QueryMotionIgnoredMotions')
    let g:IngoLibrary_QueryMotionIgnoredMotions = {}
endif
if ! exists('g:IngoLibrary_QueryMotionCustomMotions')
    let g:IngoLibrary_QueryMotionCustomMotions = {}
endif
let s:builtInMotions = ingo#dict#FromKeys(['h', "\<Left>", "\<C-h>", "\<BS>", 'l', "\<Right>", ' ', '0', "\<Home>", '^', '$', "\<End>", 'g_', 'g0', "g\<Home>", 'g^', 'gm', 'gM', 'g$', "g\<End>", '|', ';', ',', 'k', "\<Up>", "\<C-p>", 'j', "\<Down>", "\<C-j>", "\<C-n>", 'gk', "g\<Up>", 'gj', "g\<Down>", '-', '+', "\<C-m>", "\<CR>", '_', 'G', "\<C-End>", "\<C-Home>", 'gg', 'go', "\<S-Right>", 'w', "\<C-Right>", 'W', 'e', 'E', "\<S-Left>", 'b', "\<C-Left>", 'B', 'ge', 'gE', '(', ')', '{', '}', ']]', '][', '[[', '[]', 'aw', 'iw', 'aW', 'iW', 'as', 'is', 'ap', 'ip', 'a]', 'a[', 'i]', 'i[', 'a)', 'a(', 'ab', 'i)', 'i(', 'ib', 'a>', 'a<', 'i>', 'i<', 'at', 'it', 'a}', 'a{', 'aB', 'i}', 'i{', 'iB', 'a"', "a'", 'a`', 'i"', "i'", 'i`', "\<C-o>", "\t", "\<C-i>", 'g;', 'g,', '%', '[(', '[{', '])', ']}', ']m', ']M', '[m', '[M', '[#', ']#', '[*', '[/', ']*', ']/', 'H', 'M', 'L', 'n', 'N', '*', '#', 'g*', 'g#', 'gd', 'gD'], '')
call extend(s:builtInMotions, {'f': '\(.\)', 'F': '\(.\)', 't': '\(.\)' , 'T': '\(.\)', ':': '[^\r]*\(\r\)\?', "'": '\([a-zA-Z0-9''`"[\]<>^.(){}]\)', '`': '\([a-zA-Z0-9''`"[\]<>^.(){}])', "g'": '\([a-zA-Z0-9''`"[\]<>^.(){}]\)', 'g`': '\([a-zA-Z0-9''`"[\]<>^.(){}]\)', '/': '[^\r]*\(\r\)\?', '?': '[^\r]*\(\r\)\?'})
call extend(s:builtInMotions, g:IngoLibrary_QueryMotionCustomMotions, 'force')

function! ingo#query#get#Motion() abort
"******************************************************************************
"* PURPOSE:
"   Obtain a Vim motion / text object from the user. Includes any counts and
"   registers. Covers both built-in and custom operator-pending mode mappings.
"* LIMITATIONS:
"   - Mappings that consume additional characters (via getchar()) require
"     definition of what their additional keys look like in
"     g:IngoLibrary_QueryMotionCustomMotions.
"   - Unlike the built-in motions, does not handle 'timeoutlen', but will wait
"     indefinitely for additional keys.
"   - :[range] and / ? searches do not show the command-line and have to be
"     typed blindly.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   A motion that can then be appended to an operator command to apply the
"   operator to the text. Or empty String if the motion was aborted (via <Esc>).
"******************************************************************************
    let l:count = ''
    let l:register = ''
    let l:motion = ''
    let l:appendagePattern = ''
    let l:motionAppendage = ''
    while 1
	let l:key = s:GetChar()
	if l:key ==# "\<Esc>"
	    return ''
	elseif empty(l:motion)
	    if l:key ==# '"' && empty(l:register)
		let l:register = l:key  " Start of register
		continue
	    elseif l:key =~# '^[1-9]$' && empty(l:count)
		let l:count = l:key " Start of count
		continue
	    elseif len(l:register) == 1
		let l:register .= l:key " Completion of register
		continue
	    elseif l:key =~# '^\d$' && ! empty(l:count)
		let l:count .= l:key    " More count
		continue
	    endif
	endif

	if empty(l:appendagePattern)
	    let l:motion .= l:key

	    if ! empty(maparg(l:motion, 'o')) && ! has_key(g:IngoLibrary_QueryMotionIgnoredMotions, l:motion)
		break   " A complete custom mapping has been input.
	    elseif has_key(s:builtInMotions, l:motion)
		let l:appendagePattern = s:builtInMotions[l:motion]
		if empty(l:appendagePattern)
		    break   " Plain built-in motion; we're done.
		endif
	    endif
	else
	    let l:motionAppendage .= l:key
	    let l:appendageMatches = matchlist(l:motionAppendage, '^\%(' . l:appendagePattern . '\)$')
	    if empty(l:appendageMatches)
		return ''   " Invalid appendage.
	    elseif ! empty(l:appendageMatches[1])   " Something is in the first capture group.
		break   " The motion appendage is complete; we're done.
	    endif
	    " This queries more than one key.

	    " Handle <BS> for a minimal command-line experience (as those
	    " motions that take multiple keys are likely : or / or ?).
	    if l:key ==# "\<BS>" && l:motionAppendage =~# "\<BS>"
		let l:motionAppendage = substitute(l:motionAppendage, ".\<BS>$", '', '')
		redraw | echo l:motion . l:motionAppendage
	    else
		" Echo what's getting typed to give better user feedback.
		if l:motionAppendage =~# '^.$'
		    echo l:motion . l:motionAppendage
		else
		    echon l:key
		endif
	    endif
	endif
    endwhile

    return l:count . l:register . l:motion . l:motionAppendage
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
