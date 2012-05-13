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
" Copyright: (C) 2009-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	009	27-Jan-2012	ENH: Get <bang> infomation ingo s:Command() and
"				pass this on to a:Action, and make this
"				accessible to a:Action Funcrefs via a context
"				object g:CommandCompleteDirForAction_Context. 
"	008	21-Sep-2011	ENH: action and postAction now also support
"				Funcrefs instead of Ex commands. 
"				Generated command now actually demands argument
"				unless a:parameters.defaultFilename is given. 
"				a:parameters.defaultFilename can be empty,
"				resulting in a command with optional argument
"				and no filename passed to a:parameters.action;
"				the action (probably a Funcref) is supposed to
"				handle this. Beforehand, the command would be
"				aborted if the filename was empty. 
"	007	22-Jan-2011	Collapsed s:CommandWithOptionalArgument(),
"				s:CommandWithPostAction() and the direct
"				definition for a non-optional, non-postAction
"				command into s:Command(), which already handles
"				all cases anyway, getting rid of the
"				conditional. 
"				ENH: Added
"				a:parameters.FilenameProcessingFunction to allow
"				processing of the completed or typed filespec.
"				This is used by the :Vim command to correct the
"				.vimrc to ../.vimrc when the name is fully
"				typed, not completed. 
"	006	10-Dec-2010	ENH: Added a:parameters.overrideCompleteFunction
"				and returning the generated completion function
"				name in order to allow hooking into the
"				completion. This is used by the :Vim command to
"				also offer .vimrc and .gvimrc completion
"				candidates. 
"	005	27-Aug-2010	FIX: Filtering out subdirectories from the file
"				completion candidates. 
"				ENH: Added a:parameters.isIncludeSubdirs flag to
"				allow inclusion of subdirectories. Made this
"				work even when a browsefilter is set. 
"	004	06-Jul-2010	Simplified CommandCompleteDirForAction#setup()
"				interface via parameter hash that allows to omit
"				defaults and makes it more easy to extend. 
"				Implemented a:parameters.postAction, e.g. to
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

function! s:RemoveDirspec( filespec, dirspecs )
    for l:dirspec in a:dirspecs
	if strpart(a:filespec, 0, strlen(l:dirspec)) ==# l:dirspec
	    return strpart(a:filespec, strlen(l:dirspec))
	endif
    endfor
    return a:filespec
endfunction
function! s:CompleteFiles( dirspec, browsefilter, wildignore, isIncludeSubdirs, argLead )
    let l:browsefilter = (empty(a:browsefilter) ? '*' : a:browsefilter)
    let l:filespecWildcard = a:dirspec . a:argLead . l:browsefilter
    let l:save_wildignore = &wildignore
    if type(a:wildignore) == type('')
	let &wildignore = a:wildignore
    endif
    try
	let l:filespecs = split(glob(l:filespecWildcard), "\n")

	if a:isIncludeSubdirs
	    " If the a:dirspec itself contains wildcards, there may be multiple
	    " matches. 
	    let l:pathSeparator = (exists('+shellslash') && ! &shellslash ? '\' : '/')
	    let l:resolvedDirspecs = split(glob(a:dirspec), "\n")

	    " If there is a browsefilter, we need to add all directories
	    " separately, as most of them probably have been filtered away by
	    " the (file-based) a:browsefilter. 
	    if ! empty(a:browsefilter)
		let l:dirspecWildcard = a:dirspec . a:argLead . '*' . l:pathSeparator
		call extend(l:filespecs, split(glob(l:dirspecWildcard), "\n"))
		call sort(l:filespecs) " Weave the directories into the files. 
	    else
		" glob() doesn't add a trailing path separator on directories
		" unless the glob pattern has one at the end. Append the path
		" separator here to be consistent with the alternative block
		" above, the built-in completion, and because it makes sense to
		" show the path separator. 
		call map(l:filespecs, 'isdirectory(v:val) ? v:val . l:pathSeparator : v:val')
	    endif

	    return map(
	    \   l:filespecs,
	    \   'escapings#fnameescape(s:RemoveDirspec(v:val, l:resolvedDirspecs))'
	    \)
	else
	    return map(
	    \   filter(
	    \	    l:filespecs,
	    \	    '! isdirectory(v:val)'
	    \   ),
	    \   'escapings#fnameescape(fnamemodify(v:val, ":t"))'
	    \)
	endif
    finally
	let &wildignore = l:save_wildignore
    endtry
endfunction

function! s:Command( isBang, Action, PostAction, defaultFilename, FilenameProcessingFunction, dirspec, filename )
    try
	" Set up a context object so that Funcrefs can have access to the
	" information whether <bang> was given. 
	let g:CommandCompleteDirForAction_Context = { 'bang': a:isBang }

	" a:filename comes from the custom command, and must be taken as is (the
	" custom completion will have already escaped the completion). 
	" All other filespec fragments still need escaping. 
	let l:filename = (empty(a:filename) ? escapings#fnameescape(a:defaultFilename) : a:filename)

	if ! empty(a:FilenameProcessingFunction)
	    let l:filename = call(a:FilenameProcessingFunction, [l:filename])
	endif

	if type(a:Action) == 2
	    call call(a:Action, [escapings#fnameescape(a:dirspec), l:filename])
	else
	    execute a:Action . (a:isBang ? '!' : '') escapings#fnameescape(a:dirspec) . l:filename
	endif

	if ! empty(a:PostAction)
	    if type(a:PostAction) == 2
		call call(a:PostAction, [])
	    else
		execute a:PostAction
	    endif
	endif
    catch /^Vim\%((\a\+)\)\=:E/
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    finally
	unlet! g:CommandCompleteDirForAction_Context
    endtry
endfunction

let s:count = 0
function! CommandCompleteDirForAction#setup( command, dirspec, parameters )
"*******************************************************************************
"* PURPOSE:
"   Define a custom a:command that takes an (potentially optional) single file
"   argument and executes the a:parameters.action command or Funcref with it.
"   The command will have a custom completion that completes files from
"   a:dirspec, with a:parameters.browsefilter applied and
"   a:parameters.wildignore extensions filtered out. The custom completion will
"   return the list of file (/ directory / subdir path) names found. Those
"   should be interpreter relative to and thus do not include a:dirspec. 
"* ASSUMPTIONS / PRECONDITIONS:
"   None. 
"* EFFECTS / POSTCONDITIONS:
"   Defines custom a:command that takes one filename argument, which will have
"   filename completion from a:dirspec. Unless a:parameters.defaultFilename is
"   provided, the filename argument is mandatory. 
"* INPUTS:
"   a:command   Name of the custom command to be defined. 
"   a:dirspec	Directory (including trailing path separator!) from which
"		files will be completed. 
"
"   a:parameters.commandAttributes
"	    Optional :command {attr}, e.g. <buffer>, -bang, -range. 
"	    Funcrefs can access the <bang> via
"	    g:CommandCompleteDirForAction_Context.bang. 
"   a:parameters.action
"	    Ex command (e.g. 'edit', '<line2>read') to be invoked with the
"	    completed filespec. Default is the :drop / :Drop command. 
"	    Or Funcref to a function that takes the dirspec and filename (both
"	    already escaped for use in an Ex command) and performs the action
"	    itself. 
"   a:parameters.postAction
"	    Ex command to be invoked after the file has been opened via
"	    a:parameters.action. Default empty. 
"	    Or Funcref to a function that takes no arguments and performs the
"	    post actions itself. 
"   a:parameters.browsefilter
"	    File wildcard (e.g. '*.txt') used for filtering the files in
"	    a:dirspec. Default is empty string to include all (non-hidden) files. 
"	    Does not apply to subdirectories. 
"   a:parameters.wildignore
"	    Comma-separated list of file extensions to be ignored. This is
"	    similar to a:parameters.browsefilter, but with inverted semantics,
"	    only file extensions, and multiple possible values. Use empty string
"	    to disable and pass 0 (the default) to keep the current global
"	    'wildignore' setting. 
"   a:parameters.isIncludeSubdirs
"	    Flag whether subdirectories will be included in the completion
"	    matches. By default, only files in a:dirspec itself will be offered. 
"   a:parameters.defaultFilename
"	    If specified, the command will not require the filename argument,
"	    and default to this filename if none is specified. 
"   a:parameters.overrideCompleteFunction
"	    If not empty, will be used as the :command -complete=customlist,...
"	    completion function name. This hook can be used to manipulate the
"	    completion list. This overriding completion function probably will
"	    still invoke the generated custom completion function, which is
"	    therefore returned from this setup function. 
"   a:parameters.FilenameProcessingFunction
"	    If not empty, will be passed the completed (or default) filespec,
"	    and expects a processed filespec in return. (Or an empty string,
"	    which will abort the command.) 
"
"* RETURN VALUES: 
"   Name of the generated custom completion function. 
"*******************************************************************************
    let l:commandAttributes = get(a:parameters, 'commandAttributes', '')
    let l:Action = get(a:parameters, 'action', ((exists(':Drop') == 2) ? 'Drop' : 'drop'))
    let l:PostAction = get(a:parameters, 'postAction', '')
    let l:browsefilter = get(a:parameters, 'browsefilter', '')
    let l:wildignore = get(a:parameters, 'wildignore', 0)
    let l:isIncludeSubdirs = get(a:parameters, 'isIncludeSubdirs', 0)
    let l:defaultFilename = get(a:parameters, 'defaultFilename', '')
    let l:FilenameProcessingFunction = get(a:parameters, 'FilenameProcessingFunction', '')

    let s:count += 1
    let l:generatedCompleteFunctionName = 'CompleteDir' . s:count
    let l:completeFunctionName = get(a:parameters, 'overrideCompleteFunction', l:generatedCompleteFunctionName)
    execute 
    \	printf("function! %s(ArgLead, CmdLine, CursorPos)\n", l:generatedCompleteFunctionName) . 
    \	printf("    return s:CompleteFiles(%s, %s, %s, %d, a:ArgLead)\n",
    \	    string(a:dirspec), string(l:browsefilter), string(l:wildignore), l:isIncludeSubdirs
    \	) .    "endfunction"
    
    execute printf('command! -bar -nargs=%s -complete=customlist,%s %s %s call <SID>Command(<bang>0, %s, %s, %s, %s, %s, <q-args>)',
    \	(has_key(a:parameters, 'defaultFilename') ? '?' : '1'), 
    \   l:completeFunctionName,
    \   l:commandAttributes,
    \   a:command,
    \   string(l:Action),
    \   string(l:PostAction),
    \   string(l:defaultFilename),
    \	string(l:FilenameProcessingFunction),
    \   string(a:dirspec),
    \)

    return l:generatedCompleteFunctionName
endfunction

"call CommandCompleteDirForAction#setup( 'TestCommand', '~/tmp/', {})
"call CommandCompleteDirForAction#setup( 'TestCommand', '~/Ablage/', { 'browsefilter': '*.txt' })
"call CommandCompleteDirForAction#setup( 'TestCommand', '~/Ablage/', { 'postAction': "echomsg 'opened it!'" })
"call CommandCompleteDirForAction#setup( 'TestCommand', '~/Ablage/', { 'browsefilter': '*.txt', 'defaultFilename': 'test.txt' })
"call CommandCompleteDirForAction#setup('Vim', '~/Unixhome/.vim/', {'isIncludeSubdirs': 1})
"call CommandCompleteDirForAction#setup('Vim', '~/Unixhome/.vim/', {'isIncludeSubdirs': 1, 'browsefilter' : '*.vim'})

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
