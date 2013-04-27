" surroundings/Lines/Creator.vim: Create custom commands and mappings to surround whole lines with something.
"
" DEPENDENCIES:
"   - surroundings/Lines.vim autoload script
"   - ingo/mapmaker.vim autoload script
"   - repeatableMapping.vim autoload script (optional)
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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
":Command	        Insert ??? around the last changed text.
":Command {cmd}	        Execute {cmd} (e.g. :read) and insert ???
"			around the changed text.
function! surroundings#Lines#Creator#MakeCommand( commandArgs, commandName, beforeLines, afterLines, Transformer )
    " Note: No -bar; can take a sequence of Vim commands.
    execute printf('command! %s -range=-1 -nargs=* -complete=command %s call setline(<line1>, getline(<line1>)) |' .
    \	'call surroundings#Lines#SurroundCommand(%s, %s, %s, <count>, <line1>, <line2>, <q-args>)',
    \   a:commandArgs, a:commandName,
    \	string(a:beforeLines), string(a:afterLines), string(a:Transformer)
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
    execute printf('nnoremap %s %s :<C-r><C-r>=v:count ? "" : "."<CR>%s<CR>',
    \   a:mapArgs, l:lineMappingKeys, a:commandName
    \)
    execute printf('xnoremap %s %s :%s<CR>',
    \   a:mapArgs, a:keys, a:commandName
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
