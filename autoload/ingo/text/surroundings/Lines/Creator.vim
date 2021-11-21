" surroundings/Lines/Creator.vim: Create custom commands and mappings to surround whole lines with something.
"
" DEPENDENCIES:
"   - surroundings/Lines.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/mapmaker.vim autoload script
"   - repeatableMapping.vim autoload script (optional)
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	007	12-May-2014	Abort on error of created surround command.
"				CHG: Last a:Transformer argument to
"				surroundings#Lines#Creator#MakeCommand() is now
"				optional and takes a:options Dictionary.
"	006	06-Jul-2013	BUG: Visual mode mappings also apply to the
"				wrong range. Must apply the wrapping in :execute
"				for the visual mode mapping, too.
"	005	28-Apr-2013	BUG: Found the root cause of wrong range
"				application of <Leader>qq mapping: Because an
"				a:commandName that is defined through
"				surroundings#Lines#Creator#MakeCommand() does
"				not support command sequencing with <Bar>, we
"				must enclose the entire command with :execute.
"	004	21-Apr-2013	Change -range=-1 default check to use <count>
"				(now passed in separately), which maintains the
"				actual -1 default, and therefore also delivers
"				correct results when on line 1.
"	003	17-Apr-2013	Move
"				ingointegration#OperatorMappingForRangeCommand()
"				to
"				ingo#mapmaker#OperatorMappingForRangeCommand().
"	002	05-Apr-2013	Remove -bar to allow passing multiple commands.
"	001	04-Apr-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

":{range}Command	Insert ??? around {range}.
":Command		Insert ??? around the last changed text.
":Command {cmd}		Execute {cmd} (e.g. :read) and insert ???
"			around the changed text.
function! surroundings#Lines#Creator#MakeCommand( commandArgs, commandName, beforeLines, afterLines, ... )
    let l:options = (a:0 ? a:1 : {})
    " Note: No -bar; can take a sequence of Vim commands.
    execute printf('command! %s -range=-1 -nargs=* -complete=command %s call setline(<line1>, getline(<line1>)) |' .
    \	'if ! surroundings#Lines#SurroundCommand(%s, %s, %s, <count>, <line1>, <line2>, <q-args>) | echoerr ingo#err#Get() | endif',
    \   a:commandArgs, a:commandName,
    \	string(a:beforeLines), string(a:afterLines), string(l:options)
    \)
endfunction

" [count]<Leader>??	Insert ??? around [count] lines.
" [count]<Leader>?{motion}
"			Insert ??? around lines covered by {motion}.
" {Visual}<Leader>?	Insert ??? around the selection.
function! surroundings#Lines#Creator#MakeMapping( mapArgs, keys, commandName, mapName )
    let l:doubledKey = matchstr(a:keys, '\(<[[:alpha:]-]\+>\|.\)$')
    let l:lineMappingKeys = a:keys . l:doubledKey

    " Because of a:commandName defaulting to the last changed text, we have to
    " insert the "." range when no [count] is given.
    " Because an a:commandName that is defined through
    " surroundings#Lines#Creator#MakeCommand() does not support command
    " sequencing with <Bar>, we must enclose the entire command with :execute
    " (but keep the range directly before the command, so that it is invoked
    " only once) to make the transformation through repeatableMapping work.
    " (Otherwise, the appended <Bar>silent! call repeat#set() would be
    " interpreted as a command argument to a:commandName, and the wrong range
    " would be used).
    execute printf('nnoremap %s %s :<Home>execute ''<End><C-r><C-r>=v:count ? "" : "."<CR>%s''<CR>',
    \   a:mapArgs, l:lineMappingKeys, substitute(a:commandName, "'", "''", 'g')
    \)
    execute printf('xnoremap %s %s :<Home>execute "<End>" . ''%s''<CR>',
    \   a:mapArgs, a:keys, substitute(a:commandName, "'", "''", 'g')
    \)

    silent! call repeatableMapping#makeCrossRepeatable(
    \   'nnoremap ' . a:mapArgs, l:lineMappingKeys, a:mapName . 'Line',
    \   'xnoremap ' . a:mapArgs, a:keys,            a:mapName . 'Selection'
    \)
    call ingo#mapmaker#OperatorMappingForRangeCommand(a:mapArgs, a:keys, a:commandName)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
