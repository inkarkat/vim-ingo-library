" ingo/event.vim: Functions for triggering events.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.023.001	20-Jan-2015	file creation

if v:version == 703 && has('patch438') || v:version > 703
function! ingo#event#Trigger( arguments )
    execute 'doautocmd <nomodeline>' a:arguments
endfunction
else
function! ingo#event#Trigger( arguments )
    execute 'doautocmd             ' a:arguments
endfunction
endif

function! ingo#event#TriggerCustom( eventName )
    silent call ingo#event#Trigger('User ' . a:eventName)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
