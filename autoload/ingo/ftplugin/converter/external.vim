" ingo/ftplugin/converter/external.vim: Build a file converter via an external command.
"
" DEPENDENCIES:
"   - ingo/buffer/scratch.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/format.vim autoload script
"   - ingo/ftplugin/converter/external.vim autoload script
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:GetName( externalCommandDefinition )
    return (has_key(a:externalCommandDefinition, 'name') ? a:externalCommandDefinition.name : fnamemodify(a:externalCommandDefinition.command, ':t'))
endfunction
function! ingo#ftplugin#converter#external#GetNames( externalCommandDefinitions )
    return map(copy(a:externalCommandDefinitions), "s:GetName(v:val)")
endfunction
function! ingo#ftplugin#converter#external#GetArgumentMaps( externalCommandDefinitions )
    return ingo#dict#FromItems(map(copy(a:externalCommandDefinitions), "[v:val.name, get(v:val, 'arguments', [])]"))
endfunction

function! s:GetExternalCommandDefinition( externalCommandDefinitionsVariable, arguments )
    execute 'let l:externalCommandDefinitions =' a:externalCommandDefinitionsVariable

    if empty(l:externalCommandDefinitions)
	throw printf('external: No converters are configured in %s.', a:externalCommandDefinitionsVariable)
    elseif empty(a:arguments)
	if len(l:externalCommandDefinitions) > 1
	    throw 'external: Multiple converters are available; choose one: ' . join(ingo#ftplugin#converter#external#GetNames(l:externalCommandDefinitions), ', ')
	endif

	let l:command = l:externalCommandDefinitions[0]
	let l:commandArguments = ''
    else
	let l:parse = matchlist(a:arguments, '^\(\S\+\)\s\+\(.*\)$')
	let [l:selectedName, l:commandArguments] = (empty(l:parse) ? [a:arguments, ''] : l:parse[1:2])

	let l:command = get(filter(copy(l:externalCommandDefinitions), 'l:selectedName == s:GetName(v:val)'), 0, '')
	if empty(l:command)
	    if len(l:externalCommandDefinitions) > 1
		throw printf('external: No such converter: %s', l:selectedName)
	    else
		" With a single default command, these are just custom command
		" arguments passed through.
		let l:command = l:externalCommandDefinitions[0]
		let l:commandArguments = a:arguments
	    endif
	endif
    endif

    return [l:command, l:commandArguments]
endfunction

function! s:Action( actionName, commandDefinition ) abort
    let l:Action = get(a:commandDefinition, a:actionName, '')
    if ! empty(l:Action)
	call ingo#actions#ExecuteOrFunc(l:Action)
    endif
endfunction
function! s:PreAction( commandDefinition ) abort
    call s:Action('preAction', a:commandDefinition)
endfunction
function! s:PostAction( commandDefinition ) abort
    call s:Action('postAction', a:commandDefinition)
endfunction

function! s:ObtainText( commandDefinition, commandArguments, filespec )
    let l:command = call('ingo#format#Format', [a:commandDefinition.commandline] + map([a:commandDefinition.command, a:commandArguments, expand(a:filespec)], 'ingo#compat#shellescape(v:val)'))

    call s:PreAction(a:commandDefinition)
	let l:result = ingo#compat#systemlist(l:command)
	if v:shell_error != 0
	    throw 'external: Conversion failed: shell returned ' . v:shell_error . (empty(l:result) ? '' : ': ' . join(l:result))
	endif
    call s:PostAction(a:commandDefinition)

    return l:result
endfunction
function! s:FilterBuffer( commandDefinition, commandArguments, range )
    let l:command = ingo#format#Format(a:commandDefinition.commandline, ingo#compat#shellescape(a:commandDefinition.command), a:commandArguments)

    call s:PreAction(a:commandDefinition)
	silent! execute a:range . '!' . l:command
	if v:shell_error != 0
	    throw 'external: Conversion failed: shell returned ' . v:shell_error
	endif
    call s:PostAction(a:commandDefinition)
endfunction


function! ingo#ftplugin#converter#external#ToText( externalCommandDefinitionsVariable, arguments, filespec )
"******************************************************************************
"* PURPOSE:
"   Build a command that converts a file via an external command to just text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Takes over the current buffer, replaces its contents, changes its filetype
"   and locks further editing.
"* INPUTS:
"   a:externalCommandDefinitionsVariable    Name of a List of Definitions
"					    objects:
"	command:    External command to execute.
"	commandline:printf() (or ingo#format#Format()) template for inserting
"		    command, command arguments, and a:filespec to build the
"		    command-line to execute.
"	arguments:  List of possible command-line arguments supported by
"                   command, used as completion candidates.
"	filetype:   Optional value to :setlocal filetype to (default: "text")
"	extension:  Optional file extension (for
"		    ingo#ftplugin#converter#external#ExtractText())
"	preAction:  Optional Ex command or Funcref that is invoked before the
"                   external command.
"	postAction: Optional Ex command or Funcref that is invoked after
"                   successful execution of the external command.
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:externalCommandDefinitionsVariable.command, all passed by
"                   the user to the built command.
"   a:filespec      Filespec of the source file, usually representing the
"                   current buffer. It's read from the file system instead of
"                   being piped from Vim's buffer because it may be in binary
"                   format.
"* USAGE:
"   command! -bar -nargs=? FooToText call setline(1, getline(1)) |
"   \   if ! ingo#ftplugin#converter#external#ToText('g:foo_converters',
"   \   <q-args>, bufname('')) | echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = s:GetExternalCommandDefinition(a:externalCommandDefinitionsVariable, a:arguments)
	let l:text = s:ObtainText(l:commandDefinition, l:commandArguments, a:filespec)

	silent %delete _
	setlocal endofline nobinary fileencoding<
	call setline(1, l:text)
	call ingo#change#Set([1, 1], [line('$'), 1])

	let &l:filetype = get(l:commandDefinition, 'filetype', 'text')

	setlocal nomodifiable nomodified
	return 1
    catch /^external:/
	call ingo#err#SetCustomException('external')
	return 0
    endtry
endfunction
function! ingo#ftplugin#converter#external#ExtractText( externalCommandDefinitionsVariable, mods, arguments, filespec )
"******************************************************************************
"* PURPOSE:
"   Build a command that converts a file via an external command to another
"   scratch buffer that contains just text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates a new scratch buffer.
"* INPUTS:
"   a:externalCommandDefinitionsVariable    Name of a List of Definitions
"					    objects (cp.
"					    ingo#ftplugin#converter#external#ToText())
"   a:mods          Any command modifiers supplied to the built command (to open
"                   the scratch buffer in a split and control its location).
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:externalCommandDefinitionsVariable.command, all passed by
"                   the user to the built command.
"   a:filespec      Filespec of the source file, usually representing the
"                   current buffer. It's read from the file system instead of
"                   being piped from Vim's buffer because it may be in binary
"                   format.
"* USAGE:
"   command! -bar -nargs=? FooExtractText
"   \   if ! ingo#ftplugin#converter#external#ExtractText('g:foo_converters',
"   \   ingo#compat#command#Mods('<mods>'), <q-args>, bufname('')) |
"   \   echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = s:GetExternalCommandDefinition(a:externalCommandDefinitionsVariable, a:arguments)
	let l:text = s:ObtainText(l:commandDefinition, l:commandArguments, a:filespec)

	let l:status = ingo#buffer#scratch#Create('', expand('%:r') . '.' . get(l:commandDefinition, 'extension', 'txt'), 1, l:text, (empty(a:mods) ? 'enew' : a:mods . ' new'))
	if l:status == 0
	    call ingo#err#Set('Failed to open scratch buffer.')
	    return 0
	endif
	return 1
    catch /^external:/
	call ingo#err#SetCustomException('external')
	return 0
    endtry
endfunction

function! ingo#ftplugin#converter#external#Filter( externalCommandDefinitionsVariable, range, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that filters the current buffer by filtering its contents
"   through an external command.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current buffer.
"* INPUTS:
"   a:externalCommandDefinitionsVariable    Name of a List of Definitions
"                                           objects (cp.
"                                           ingo#ftplugin#converter#external#ToText())
"   a:range         Range of lines to be filtered.
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:externalCommandDefinitionsVariable.command, all passed by
"                   the user to the built command.
"   a:preCommand    Optional Ex command to be executed before anything else.
"                   a:externalCommandDefinitionsVariable.preAction can configure
"                   different pre commands for each definition, whereas this one
"                   applies to all definitions.
"* USAGE:
"   command! -bar -range=% -nargs=? FooPrettyPrint call setline(1, getline(1)) |
"   \   if ! ingo#ftplugin#converter#external#Filter('g:Foo_PrettyPrinters',
"   \       '<line1>,<line2>', <q-args>) | echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = s:GetExternalCommandDefinition(a:externalCommandDefinitionsVariable, a:arguments)

	if a:0
	    execute a:1
	endif

	call s:FilterBuffer(l:commandDefinition, l:commandArguments, a:range)

	let l:targetFiletype = get(l:commandDefinition, 'filetype', '')
	if ! empty(l:targetFiletype)
	    let &l:filetype = l:targetFiletype
	endif

	return 1
    catch /^external:/
	call ingo#err#SetCustomException('external')
	return 0
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! ingo#ftplugin#converter#external#DifferentFiletype( targetFiletype, externalCommandDefinitionsVariable, range, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that converts the current buffer's contents to a different
"   a:targetFiletype by filtering its contents through an external command.
"   Like ingo#ftplugin#converter#external#Filter(), but additionally sets
"   a:targetFiletype on a successful execution.
"* INPUTS:
"   a:targetFiletype    Target 'filetype' that the buffer is set to if the
"                       filtering has been successful. This overrides
"                       a:externalCommandDefinitionsVariable.filetype (which is
"                       not supposed to be used here).
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    let l:success = call('ingo#ftplugin#converter#external#Filter', [a:externalCommandDefinitionsVariable, a:range, a:arguments] + a:000)
    if l:success
	let &l:filetype = a:targetFiletype
    endif
    return l:success
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
