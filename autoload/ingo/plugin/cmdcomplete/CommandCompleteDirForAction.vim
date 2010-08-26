" CommandCompleteDirForAction.vim: Define custom command to complete files from
" a specified directory. 
"
" DESCRIPTION:
"   In GVIM, one can define a menu item which uses browse() in combination with
"   an Ex command to open a file browser dialog in a particular directory, lets
"   the user select a file, and then uses that file for a predefined Ex command. 
"   This script provides a function to define similar custom commands for use
"   without a GUI file selector, relying instead on custom command completion. 
"
" USAGE:
" EXAMPLE:
"   Define a command :BrowseTemp that edits a text file from the system TEMP
"   directory. >
"	call CommandCompleteDirForAction#setup(
"	\   '',
"	\   'BrowseTemp',
"	\   'edit',
"	\   (exists('$TEMP') ? $TEMP : '/tmp'),
"	\   '*.txt',
"	\   '',
"	\   ''
"	\)
"   You can then use the new command with file completion: 
"	:BrowseTemp f<Tab> -> :BrowseTemp foo.txt
"
" INSTALLATION:
"   Put the script into your user or system Vim autoload directory (e.g.
"   ~/.vim/autoload). 

" DEPENDENCIES:
"   - escapings.vim autoload script. 

" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2009-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	004	06-Jul-2010	Simplified CommandCompleteDirForAction#setup()
"				interface via parameter hash that allows to omit
"				defaults and makes it more easy to extend. 
"				Implemented a:parameter.postAction, e.g. to
"				:setfiletype after opening the file. 
"	003	27-Oct-2009	BUG: With optional argument, the a:filename
"				passed to s:CommandWithOptionalArgument() must
"				not be escaped, only all other filespec
"				fragments. 
"	002	26-Oct-2009	Added to arguments: a:commandAttributes e.g. to
"				make buffer-local commands, a:defaultFilename to
"				make the filename argument optional. 
"	001	26-Oct-2009	file creation

let s:save_cpo = &cpo
set cpo&vim

function! s:CompleteFiles( dirspec, browsefilter, wildignore, argLead )
    let l:browsefilter = (empty(a:browsefilter) ? '*' : a:browsefilter)
    let l:filespecWildcard = a:dirspec . a:argLead . l:browsefilter
    let l:save_wildignore = &wildignore
    if type(a:wildignore) == type('')
	let &wildignore = a:wildignore
    endif
    try
	return map(split(glob(l:filespecWildcard), "\n"), 'escapings#fnameescape(fnamemodify(v:val, ":t"))')
    finally
	let &wildignore = l:save_wildignore
    endtry
endfunction

function! s:CommandWithOptionalArgument( action, postAction, defaultFilename, dirspec, filename )
    try
	" a:filename comes from the custom command, and must be taken as is (the
	" custom completion will have already escaped the completion). 
	" All other filespec fragments still need escaping. 
	execute a:action escapings#fnameescape(a:dirspec) . (empty(a:filename) ? escapings#fnameescape(a:defaultFilename) : a:filename)

	if ! empty(a:postAction)
	    execute a:postAction
	endif
    catch /^Vim\%((\a\+)\)\=:E/
	echohl ErrorMsg
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echomsg v:errmsg
	echohl None
    endtry
endfunction
function! s:CommandWithPostAction( action, postAction, dirspec, filename )
    try
	" a:filename comes from the custom command, and must be taken as is (the
	" custom completion will have already escaped the completion). 
	" All other filespec fragments still need escaping. 
	execute a:action escapings#fnameescape(a:dirspec) . a:filename

	if ! empty(a:postAction)
	    execute a:postAction
	endif
    catch /^Vim\%((\a\+)\)\=:E/
	echohl ErrorMsg
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echomsg v:errmsg
	echohl None
    endtry
endfunction

let s:count = 0
function! CommandCompleteDirForAction#setup( command, dirspec, parameters )
"*******************************************************************************
"* PURPOSE:
"   Define a custom a:command that takes an (potentially optional) single file
"   argument and executes the a:action Ex command with it. The command will have
"   a custom completion that completes files from a:dirspec, with
"   a:parameters.browsefilter applied and a:parameters.wildignore extensions
"   filtered out. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   Defines custom a:command that takes one filename argument, which will have
"   filename completion from a:dirspec. If a:parameters.defaultFilename is not
"   empty, the filename argument is optional. 
"* INPUTS:
"   a:command   Name of the custom command to be defined. 
"   a:dirspec	Directory (including trailing path separator!) from which
"		files will be completed. 
"
"   a:parameters.commandAttributes
"	    Optional :command {attr}, e.g. <buffer>. 
"   a:parameters.action
"	    Ex command (e.g. 'edit', 'split') to be invoked with the completed
"	    filespec. Default is the :drop / :Drop command. 
"   a:parameters.postAction
"	    Ex command to be invoked after the file has been opened via
"	    a:parameters.action. Default empty. 
"   a:parameters.browsefilter
"	    File wildcard (e.g. '*.txt') used for filtering the files in
"	    a:dirspec. Default is empty string to include all (non-hidden) files. 
"   a:parameters.wildignore
"	    Comma-separated list of file extensions to be ignored. This is
"	    similar to a:parameters.browsefilter, but with inverted semantics,
"	    only file extensions, and multiple possible values. Use empty string
"	    to disable and pass 0 (the default) to keep the current global
"	    'wildignore' setting. 
"   a:parameters.defaultFilename
"	    If not empty, the command will not require the filename argument,
"	    and default to this filename if none is specified. 
"* RETURN VALUES: 
"	List of file names found (without the dirspec). 
"*******************************************************************************
    let l:commandAttributes = get(a:parameters, 'commandAttributes', '')
    let l:action = get(a:parameters, 'action', ((exists(':Drop') == 2) ? 'Drop' : 'drop'))
    let l:postAction = get(a:parameters, 'postAction', '')
    let l:browsefilter = get(a:parameters, 'browsefilter', '')
    let l:wildignore = get(a:parameters, 'wildignore', 0)
    let l:defaultFilename = get(a:parameters, 'defaultFilename', '')

    let s:count += 1
    execute 
    \ printf("function! CompleteDir%s(ArgLead, CmdLine, CursorPos)\n", s:count) . 
    \ printf("    return s:CompleteFiles(%s, %s, %s, a:ArgLead)\n", string(a:dirspec), string(l:browsefilter), string(l:wildignore)) .
    \        "endfunction"
    
    let l:isArgumentOptional = ! empty(l:defaultFilename)
    if l:isArgumentOptional
	execute printf('command! -bar -nargs=? -complete=customlist,CompleteDir%s %s %s call <SID>CommandWithOptionalArgument(%s, %s, %s, %s, <q-args>)',
	\   s:count,
	\   l:commandAttributes,
	\   a:command,
	\   string(l:action),
	\   string(l:postAction),
	\   string(l:defaultFilename),
	\   string(a:dirspec),
	\)
    elseif ! empty(l:postAction)
	execute printf('command! -bar -nargs=1 -complete=customlist,CompleteDir%s %s %s call <SID>CommandWithPostAction(%s, %s, %s, <q-args>)',
	\   s:count,
	\   l:commandAttributes,
	\   a:command,
	\   string(l:action),
	\   string(l:postAction),
	\   string(a:dirspec),
	\)
    else
	execute printf('command! -bar -nargs=1 -complete=customlist,CompleteDir%s %s %s %s %s<args>',
	\   s:count,
	\   l:commandAttributes,
	\   a:command,
	\   l:action,
	\   a:dirspec
	\)
	" Unfortunately, we cannot simply append l:postAction to the direct
	" definition of the command, as some l:action command (like :drop)
	" cannot be chained via <Bar>. Wrapping the l:action in an :execute
	" would force escaping of the quoting. 
	" Additionally, the <Bar> chaining wouldn't short-circuit; i.e. the
	" l:postAction would always execute, even if l:action failed. 
	" Thus, we handle l:postAction via a separate s:CommandWithPostAction()
	" wrapper function. 
    endif
endfunction

"call CommandCompleteDirForAction#setup( 'TestCommand', '~/Ablage/', { 'browsefilter': '*.txt' })
"call CommandCompleteDirForAction#setup( 'TestCommand', '~/Ablage/', { 'postAction': "echomsg 'opened it!'" })
"call CommandCompleteDirForAction#setup( 'TestCommand', '~/Ablage/', { 'browsefilter': '*.txt', 'defaultFilename': 'test.txt' })

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
