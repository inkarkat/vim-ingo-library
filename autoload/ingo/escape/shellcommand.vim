" ingo/escape/command.vim: Additional escapings of commands.
"
" DEPENDENCIES:
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	08-Aug-2013	file creation

function! ingo#escape#command#exescape( command )
"*******************************************************************************
"* PURPOSE:
"   Escape a shell command (potentially consisting of multiple commands and
"   including (already quoted) command-line arguments) so that it can be used in
"   Ex commands. For example: 'hostname && ps -ef | grep -e "foo"'.
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:command	    Shell command-line.
"
"* RETURN VALUES:
"   Escaped shell command to be passed to the !{cmd} or :r !{cmd} commands.
"*******************************************************************************
    if exists('*fnameescape')
	return join(map(split(a:command, ' '), 'fnameescape(v:val)'), ' ')
    else
	return escape(a:command, '\%#|' )
    endif
endfunction

function! ingo#escape#command#shellcmdescape( command )
"******************************************************************************
"* PURPOSE:
"   Wrap the entire a:command in double quotes on Windows.
"   This is necessary when passing a command to cmd.exe which has arguments that
"   are enclosed in double quotes, e.g.
"	""%SystemRoot%\system32\dir.exe" /B "%ProgramFiles%"".
"
"* EXAMPLE:
"   execute '!' ingo#escape#command#shellcmdescape(escapings#shellescape($ProgramFiles .
"   '/foobar/foo.exe', 1) . ' ' . escapings#shellescape(args, 1))
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:command	    Single shell command, with optional arguments.
"		    The shell command should already have been escaped via
"		    shellescape().
"* RETURN VALUES:
"   Escaped command to be used in a :! command or inside a system() call.
"******************************************************************************
    return (ingo#os#IsWinOrDos() ? '"' . a:command . '"' : a:command)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
