" ingo/ftplugin/converter/builder.vim: Build a file converter via an Ex command.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:FilterBuffer( commandDefinition, commandArguments, range, isBang )
    if has_key(a:commandDefinition, 'commandline')
	let l:commandLine = ingo#actions#ValueOrFunc(a:commandDefinition.commandline, {'definition': a:commandDefinition, 'range': a:range, 'isBang': a:isBang, 'arguments': a:commandArguments})
	if has_key(a:commandDefinition, 'command')
	    let l:command = ingo#format#Format(l:commandLine, ingo#compat#shellescape(a:commandDefinition.command), a:commandArguments)
	else
	    let l:command = ingo#format#Format(l:commandLine, a:commandArguments)
	endif
    elseif has_key(a:commandDefinition, 'command')
	let l:command = a:commandDefinition.command
    else
	throw 'converter: Neither command nor commandline defined for ' . get(a:commandDefinition, 'name', string(a:commandDefinition))
    endif

    call ingo#ftplugin#converter#PreAction(a:commandDefinition)
	silent! execute a:range . l:command
	if l:command =~# '^!' && v:shell_error != 0
	    throw 'converter: Conversion failed: shell returned ' . v:shell_error
	endif
    call ingo#ftplugin#converter#PostAction(a:commandDefinition)
endfunction

function! ingo#ftplugin#converter#builder#Filter( commandDefinitionsVariable, range, isBang, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that filters the current buffer by filtering its contents
"   through an command.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current buffer.
"* INPUTS:
"   a:commandDefinitionsVariable    Name of a List of Definitions objects:
"	command:    Command to execute.
"	commandline:printf() (or ingo#format#Format()) template for inserting
"		    command and command arguments to build the Ex command-line
"		    to execute. a:range is prepended to this. To filter through
"		    an external command, start the commandline with "!".
"		    Or a Funcref that gets passed the invocation context (and
"		    Dictionary with these keys: definition, range, isBang,
"		    arguments) and should return the (dynamically generated)
"		    commandline.
"	arguments:  List of possible command-line arguments supported by
"                   command, used as completion candidates.
"	filetype:   Optional value to :setlocal filetype to.
"	extension:  Optional file extension (for
"		    ingo#ftplugin#converter#external#ExtractText())
"	preAction:  Optional Ex command or Funcref that is invoked before the
"                   external command.
"	postAction: Optional Ex command or Funcref that is invoked after
"                   successful execution of the external command.
"   a:range         Range of lines to be filtered.
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:commandDefinitionsVariable.command, all passed by the user
"                   to the built command.
"   a:preCommand    Optional Ex command to be executed before anything else.
"                   a:commandDefinitionsVariable.preAction can configure
"                   different pre commands for each definition, whereas this one
"                   applies to all definitions.
"* USAGE:
"   command! -bang -bar -range=% -nargs=? FooPrettyPrint call setline(1, getline(1)) |
"   \   if ! ingo#ftplugin#converter#builder#Filter('g:Foo_PrettyPrinters',
"   \       '<line1>,<line2>', <bang>0, <q-args>) | echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:commandDefinitionsVariable, a:arguments)

	if a:0
	    execute a:1
	endif

	call s:FilterBuffer(l:commandDefinition, l:commandArguments, a:range, a:isBang)

	let l:targetFiletype = get(l:commandDefinition, 'filetype', '')
	if ! empty(l:targetFiletype)
	    let &l:filetype = l:targetFiletype
	endif

	return 1
    catch /^converter:/
	call ingo#err#SetCustomException('converter')
	return 0
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! ingo#ftplugin#converter#builder#DifferentFiletype( targetFiletype, commandDefinitionsVariable, range, isBang, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that converts the current buffer's contents to a different
"   a:targetFiletype by filtering its contents through an Ex command.
"   Like ingo#ftplugin#converter#builder#Filter(), but additionally sets
"   a:targetFiletype on a successful execution.
"* INPUTS:
"   a:targetFiletype    Target 'filetype' that the buffer is set to if the
"                       filtering has been successful. This overrides
"                       a:commandDefinitionsVariable.filetype (which is not
"                       supposed to be used here).
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    let l:success = call('ingo#ftplugin#converter#builder#Filter', [a:commandDefinitionsVariable, a:range, a:isBang, a:arguments] + a:000)
    if l:success
	let &l:filetype = a:targetFiletype
    endif
    return l:success
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
