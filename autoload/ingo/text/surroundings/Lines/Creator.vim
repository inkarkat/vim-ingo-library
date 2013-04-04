" surroundings/Lines/Creator.vim: Create custom commands and mappings to surround whole lines with something.
"
" DEPENDENCIES:
"   - surroundings/Lines.vim autoload script
"   - ingointegration.vim autoload script
"   - repeatableMapping.vim autoload script (optional)
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	04-Apr-2013	file creation
let s:save_cpo = &cpo
set cpo&vim

function! surroundings#Lines#Creator#MakeCommand( commandArgs, commandName, beforeLines, afterLines, Transformer )
    execute printf('command! -bar %s -range=-1 -nargs=* -complete=command %s call setline(<line1>, getline(<line1>)) |' .
    \	'call surroundings#Lines#SurroundCommand(%s, %s, %s, <line1>, <line2>, <q-args>)',
    \   a:commandArgs, a:commandName,
    \	string(a:beforeLines), string(a:afterLines), string(a:Transformer)
    \)
endfunction

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
    call ingointegration#OperatorMappingForRangeCommand(a:mapArgs, a:keys, a:commandName)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
