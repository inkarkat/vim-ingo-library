" ingo/compat.vim: Functions for backwards compatibility with old Vim versions.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/options.vim autoload script
"   - ingo/strdisplaywidth.vim autoload script
"
" Copyright: (C) 2013-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.026.017	11-Aug-2016	Add ingo#compat#strgetchar() and
"				ingo#compat#strcharpart(), introduced in Vim
"				7.4.1730.
"				Support ingo#compat#strchars() optional {skipcc}
"				argument, introduced in Vim 7.4.755.
"   1.025.016	15-Jul-2016	Add ingo#compat#sha256(), with a fallback to an
"				external sha256sum command.
"   1.024.015	23-Apr-2015	Add ingo#compat#shiftwidth(), taken from :h
"				shiftwidth().
"   1.022.014	25-Sep-2014	FIX: Non-list argument to glob() for old Vim
"				versions.
"   1.022.013	23-Sep-2014	FIX: globpath() with {list} argument is only
"				available with Vim 7.4.279.
"   1.022.012	22-Sep-2014	Add ingo#compat#glob() and
"				ingo#compat#globpath().
"   1.021.011	12-Jun-2014	Make test for 'virtualedit' option values also
"				account for unrelated values.
"   1.021.010	11-Jun-2014	Add ingo#compat#uniq().
"   1.020.009	30-May-2014	Add ingo#compat#abs().
"   1.018.008	12-Apr-2014	FIX: Off-by-one in emulated
"				ingo#compat#strdisplaywidth() reported one too
"				few.
"   1.017.007	19-Feb-2014	Add workarounds for fnameescape() bugs on
"				Windows for ! and [] characters.
"   1.015.006	20-Nov-2013	Add ingo#compat#setpos().
"   1.012.005	02-Sep-2013	FIX: Contrary to the old maparg(), <SID> doesn't
"				get automatically translated into <SNR>NNN_
"				when using the new ,{dict} overload. Perform
"				this substitution ourselves to maintain
"				compatibility.
"   1.012.004	09-Aug-2013	Add ingo#compat#maparg().
"   1.012.003	08-Aug-2013	Add ingo#compat#fnameescape() and
"				ingo#compat#shellescape() from escapings.vim.
"   1.008.002	07-Jun-2013	Move EchoWithoutScrolling#DetermineVirtColNum()
"				implementaion in here.
"   1.004.001	04-Apr-2013	file creation

if exists('*shiftwidth')
    function! ingo#compat#shiftwidth()
	return shiftwidth()
    endfunction
else
    function! ingo#compat#shiftwidth()
	return &shiftwidth
    endfunction
endif

if exists('*strdisplaywidth')
    function! ingo#compat#strdisplaywidth( expr, ... )
	return call('strdisplaywidth', [a:expr] + a:000)
    endfunction
else
    function! ingo#compat#strdisplaywidth( expr, ... )
	let l:expr = (a:0 ? repeat(' ', a:1) . a:expr : a:expr)
	let i = 1
	while 1
	    if ! ingo#strdisplaywidth#HasMoreThan(l:expr, i)
		return i - (a:0 ? a:1 : 0)
	    endif
	    let i += 1
	endwhile
    endfunction
endif

if exists('*strchars')
    if v:version == 704 && has('patch755') || v:version > 704
	function! ingo#compat#strchars( ... )
	    return call('strchars', a:000)
	endfunction
    else
	function! ingo#compat#strchars( expr, ... )
	    return (a:0 && a:1 ? strlen(substitute(a:expr, ".", "x", "g")) : strchars(a:expr))
	endfunction
    endif
else
    function! ingo#compat#strchars( expr, ... )
	return len(split(a:expr, '\zs'))
    endfunction
endif

if exists('*strgetchar')
    function! ingo#compat#strgetchar( expr, index )
	return strgetchar(a:expr, a:index)
    endfunction
else
    function! ingo#compat#strgetchar( expr, index )
	return char2nr(matchstr(a:expr, '.\{' . a:index . '}\zs.'))
    endfunction
endif

if exists('*strcharpart')
    function! ingo#compat#strcharpart( ... )
	return call('strcharpart', a:000)
    endfunction
else
    function! ingo#compat#strcharpart( src, start, ... )
	let [l:start, l:len] = [a:start, a:0 ? a:1 : 0]
	if l:start < 0
	    let l:len += l:start
	    let l:start = 0
	endif

	return matchstr(a:src, '.\{' . l:start . '}\zs.' . (a:0 ? '\{,' . max([0, l:len]) . '}' : '*'))
    endfunction
endif

if exists('*abs')
    function! ingo#compat#abs( expr )
	return abs(a:expr)
    endfunction
else
    function! ingo#compat#abs( expr )
	return (a:expr < 0 ? -1 : 1) * a:expr
    endfunction
endif

if exists('*uniq')
    function! ingo#compat#uniq( list )
	return uniq(a:list)
    endfunction
else
    function! ingo#compat#uniq( list )
	return ingo#collections#UniqueSorted(a:list)
    endfunction
endif


function! ingo#compat#fnameescape( filespec )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in Ex commands.
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"* RETURN VALUES:
"   Escaped filespec to be passed as a {file} argument to an Ex command.
"*******************************************************************************
    if exists('*fnameescape')
	if ingo#os#IsWindows()
	    let l:filespec = a:filespec

	    " XXX: fnameescape() on Windows mistakenly escapes the "!"
	    " character, which makes Vim treat the "foo!bar" filespec as if a
	    " file "!bar" existed in an intermediate directory "foo". Cp.
	    " http://article.gmane.org/gmane.editors.vim.devel/22421
	    let l:filespec = substitute(fnameescape(l:filespec), '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\!', '!', 'g')

	    " XXX: fnameescape() on Windows does not escape the "[" character
	    " (like on Linux), but Windows understands this wildcard and expands
	    " it to an existing file. As escaping with \ does not work (it is
	    " treated like a path separator), turn this into the neutral [[],
	    " but only if the file actually exists.
	    if a:filespec =~# '\[[^/\\]\+\]' && filereadable(fnamemodify(a:filespec, ':p')) " Need to expand to absolute path (but not use expand() because of the glob!) because filereadable() does not understand stuff like "~/...".
		let l:filespec = substitute(l:filespec, '\[', '[[]', 'g')
	    endif

	    return l:filespec
	else
	    return fnameescape(a:filespec)
	endif
    else
	" Note: On Windows, backslash path separators and some other Unix
	" shell-specific characters mustn't be escaped.
	return escape(a:filespec, " \t\n*?`%#'\"|<" . (ingo#os#IsWinOrDos() ? '' : '![{$\'))
    endif
endfunction

function! ingo#compat#shellescape( filespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in shell commands.
"   The filespec will be quoted properly.
"   When the {special} argument is present and it's a non-zero Number, then
"   special items such as "!", "%", "#" and "<cword>" will be preceded by a
"   backslash.  This backslash will be removed again by the |:!| command.
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"   a:special	    Flag whether special items will be escaped, too.
"
"* RETURN VALUES:
"   Escaped filespec to be used in a :! command or inside a system() call.
"*******************************************************************************
    let l:isSpecial = (a:0 ? a:1 : 0)
    let l:specialShellescapeCharacters = "\n%#'!"
    if exists('*shellescape')
	if a:0
	    if v:version < 702
		" The shellescape({string}) function exists since Vim 7.0.111,
		" but shellescape({string}, {special}) was only introduced with
		" Vim 7.2. Emulate the two-argument function by (crudely)
		" escaping special characters for the :! command.
		return shellescape((l:isSpecial ? escape(a:filespec, l:specialShellescapeCharacters) : a:filespec))
	    else
		return shellescape(a:filespec, l:isSpecial)
	    endif
	else
	    return shellescape(a:filespec)
	endif
    else
	let l:escapedFilespec = (l:isSpecial ? escape(a:filespec, l:specialShellescapeCharacters) : a:filespec)

	if ingo#os#IsWinOrDos()
	    return '"' . l:escapedFilespec . '"'
	else
	    return "'" . l:escapedFilespec . "'"
	endif
    endif
endfunction

if v:version == 704 && has('patch279') || v:version > 704
    " This one has both {nosuf} and {list}.
    function! ingo#compat#glob( ... )
	return call('glob', a:000)
    endfunction
    function! ingo#compat#globpath( ... )
	return call('globpath', a:000)
    endfunction
elseif v:version == 703 && has('patch465') || v:version > 703
    " This one has glob() with both {nosuf} and {list}.
    function! ingo#compat#glob( ... )
	return call('glob', a:000)
    endfunction
    function! ingo#compat#globpath( ... )
	let l:list = (a:0 > 3 && a:4)
	let l:result = call('globpath', a:000[0:2])
	return (l:list ? split(l:result, '\n') : l:result)
    endfunction
elseif v:version == 702 && has('patch051') || v:version > 702
    " This one has {nosuf}.
    function! ingo#compat#glob( ... )
	let l:list = (a:0 > 2 && a:3)
	let l:result = call('glob', a:000[0:1])
	return (l:list ? split(l:result, '\n') : l:result)
    endfunction
    function! ingo#compat#globpath( ... )
	let l:list = (a:0 > 3 && a:4)
	let l:result = call('globpath', a:000[0:2])
	return (l:list ? split(l:result, '\n') : l:result)
    endfunction
else
    " This one has neither {nosuf} nor {list}.
    function! ingo#compat#glob( ... )
	let l:nosuf = (a:0 > 1 && a:2)
	let l:list = (a:0 > 2 && a:3)

	if l:nosuf
	    let l:save_wildignore = &wildignore
	    set wildignore=
	endif
	try
	    let l:result = call('glob', [a:1])
	    return (l:list ? split(l:result, '\n') : l:result)
	finally
	    if exists('l:save_wildignore')
		let &wildignore = l:save_wildignore
	    endif
	endtry
    endfunction
    function! ingo#compat#globpath( ... )
	let l:nosuf = (a:0 > 2 && a:3)
	let l:list = (a:0 > 3 && a:4)

	if l:nosuf
	    let l:save_wildignore = &wildignore
	    set wildignore=
	endif
	try
	    let l:result = call('globpath', a:000[0:1])
	    return (l:list ? split(l:result, '\n') : l:result)
	finally
	    if exists('l:save_wildignore')
		let &wildignore = l:save_wildignore
	    endif
	endtry
    endfunction
endif

if v:version == 703 && has('patch32') || v:version > 703
    function! ingo#compat#maparg( name, ... )
	let l:args = [a:name, '', 0, 1]
	if a:0 > 0
	    let l:args[1] = a:1
	endif
	if a:0 > 1
	    let l:args[2] = a:2
	endif
	let l:mapInfo = call('maparg', l:args)

	" Contrary to the old maparg(), <SID> doesn't get automatically
	" translated into <SNR>NNN_ here.
	return substitute(l:mapInfo.rhs, '\c<SID>', '<SNR>' . l:mapInfo.sid . '_', 'g')
    endfunction
else
    function! ingo#compat#maparg( name, ... )
	let l:rhs = call('maparg', [a:name] + a:000)
	let l:rhs = substitute(l:rhs, '|', '<Bar>', 'g')    " '|' must be escaped, or the map command will end prematurely.
	return l:rhs
    endfunction
endif

if v:version == 703 && has('patch590') || v:version > 703
    function! ingo#compat#setpos( expr, list )
	return setpos(a:expr, a:list)
    endfunction
else
    function! s:IsOnOrAfter( pos1, pos2 )
	return (a:pos2[1] > a:pos1[1] || a:pos2[1] == a:pos1[1] && a:pos2[2] >= a:pos1[2])
    endfunction
    function! ingo#compat#setpos( expr, list )
	" Vim versions before 7.3.590 cannot set the selection directly.
	let l:save_cursor = getpos('.')
	if a:expr ==# "'<"
	    let l:status = setpos('.', a:list)
	    if l:status != 0 | return l:status | endif
	    if s:IsOnOrAfter(a:list, getpos("'>"))
		execute "normal! vg`>\<Esc>"
	    else
		" We cannot maintain the position of the end of the selection,
		" as it is _before_ the new start, and would therefore make Vim
		" swap the two mark positions.
		execute "normal! v\<Esc>"
	    endif
	    call setpos('.', l:save_cursor)
	    return 0
	elseif a:expr ==# "'>"
	    if &selection ==# 'exclusive' && ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
		" We may have to select the last character in a line.
		let l:save_virtualedit = &virtualedit
		set virtualedit=onemore
	    endif
	    try
		let l:status = setpos('.', a:list)
		if l:status != 0 | return l:status | endif
		if s:IsOnOrAfter(getpos("'<"), a:list)
		    execute "normal! vg`<o\<Esc>"
		else
		    " We cannot maintain the position of the start of the selection,
		    " as it is _after_ the new end, and would therefore make Vim
		    " swap the two mark positions.
		    execute "normal! v\<Esc>"
		endif
		call setpos('.', l:save_cursor)
		return 0
	    finally
		if exists('l:save_virtualedit')
		    let &virtualedit = l:save_virtualedit
		endif
	    endtry
	else
	    return setpos(a:expr, a:list)
	endif
    endfunction
endif

if exists('*sha256')
    function! ingo#compat#sha256( string )
	return sha256(a:string)
    endfunction
elseif executable('sha256sum')
    let s:printStringCommandTemplate = (ingo#os#IsWinOrDos() ? 'echo.%s' : 'printf %%s %s')
    function! ingo#compat#sha256( string )
	return get(split(system(printf(s:printStringCommandTemplate . "|sha256sum", ingo#compat#shellescape(a:string)))), 0, '')
    endfunction
else
    function! ingo#compat#sha256( string )
	throw 'ingo#compat#sha256: Not implemented here'
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
