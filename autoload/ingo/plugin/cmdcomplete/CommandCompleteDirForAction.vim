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
"	call CommandCompleteDirForAction#setup( 'BrowseTemp', 'edit', (exists('$TEMP') ? $TEMP : '/tmp'), '*.txt', '')
"   You can then use the new command with file completion: 
"	:BrowseTemp f<Tab> -> :BrowseTemp foo.txt
"
" INSTALLATION:
"   Put the script into your user or system Vim autoload directory (e.g.
"   ~/.vim/autoload). 

" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 

" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	26-Oct-2009	file creation

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

let s:count = 0
function! CommandCompleteDirForAction#setup( command, action, dirspec, browsefilter, wildignore )
"*******************************************************************************
"* PURPOSE:
"   Define a custom a:command that takes a single file argument and executes the
"   a:action Ex command with it. The command will have a custom completion that
"   completes files from a:dirspec, with a:browsefilter applied and a:wildignore
"   extensions filtered out. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	a:command   Name of the custom command to be defined. 
"	a:action    Ex command (e.g. 'edit', 'split') to be invoked with the
"		    completed filespec. 
"	a:dirspec   Directory (including trailing path separator!) from which
"		    files will be completed. 
"	a:browsefilter	File wildcard (e.g. '*.txt') used for filtering the
"			files in a:dirspec. Use empty string to include all
"			(non-hidden) files. 
"	a:wildignore	Comma-separated list of file extensions to be ignored.
"			This is similar to a:browsefilter, but with inverted
"			semantics, only file extensions, and multiple possible
"			values. Use empty string to disable and pass 0 to keep
"			the current global 'wildignore' setting. 
"* RETURN VALUES: 
"	List of file names found (without the dirspec). 
"*******************************************************************************
    let s:count += 1
    execute 
    \ printf("function! CompleteDir%s(ArgLead, CmdLine, CursorPos)\n", s:count) . 
    \ printf("    return s:CompleteFiles(%s, %s, %s, a:ArgLead)\n", string(a:dirspec), string(a:browsefilter), string(a:wildignore)) .
    \        "endfunction"
    
    execute printf('command! -bar -nargs=1 -complete=customlist,CompleteDir%s %s %s %s<args>', s:count, a:command, a:action, a:dirspec)
endfunction

"call CommandCompleteDirForAction#setup( 'TestCommand', 'split', 'e:/a/ablage/', '*.txt', 0)

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
