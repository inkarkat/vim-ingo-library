" ingo/ftplugin/converter/builder.vim: Build a file converter via an Ex command.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:FilterBuffer( commandDefinition, commandArguments, range )
    let l:command = ingo#format#Format(a:commandDefinition.commandline, ingo#compat#shellescape(a:commandDefinition.command), a:commandArguments)

    call ingo#ftplugin#converter#PreAction(a:commandDefinition)
	silent! execute a:range . l:command
	if l:command =~# '^!' && v:shell_error != 0
	    throw 'converter: Conversion failed: shell returned ' . v:shell_error
	endif
    call ingo#ftplugin#converter#PostAction(a:commandDefinition)
endfunction

function! ingo#ftplugin#converter#builder#Filter( commandDefinitionsVariable, range, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that filters the current buffer by filtering its contents
"   through an command.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current buffer.
"* INPUTS:
"   a:commandDefinitionsVariable    Name of a List of Definitions objects (cp.
"                                   ingo#ftplugin#converter#external#ToText())
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
"   command! -bar -range=% -nargs=? FooPrettyPrint call setline(1, getline(1)) |
"   \   if ! ingo#ftplugin#converter#builder#Filter('g:Foo_PrettyPrinters',
"   \       '<line1>,<line2>', <q-args>) | echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:commandDefinitionsVariable, a:arguments)

	if a:0
	    execute a:1
	endif

	call s:FilterBuffer(l:commandDefinition, l:commandArguments, a:range)

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
function! ingo#ftplugin#converter#builder#DifferentFiletype( targetFiletype, commandDefinitionsVariable, range, arguments, ... ) abort
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
    let l:success = call('ingo#ftplugin#converter#builder#Filter', [a:commandDefinitionsVariable, a:range, a:arguments] + a:000)
    if l:success
	let &l:filetype = a:targetFiletype
    endif
    return l:success
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
