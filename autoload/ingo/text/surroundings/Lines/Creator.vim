" surroundings/Lines/Creator.vim: Create custom commands and mappings to surround whole lines with something.
"
" DEPENDENCIES:
"   - surroundings/Lines.vim autoload script
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

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
