" ingo/msg.vim: Functions for Vim errors and warnings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.000.001	22-Jan-2013	file creation

function! ingo#msg#WarningMsg( text )
    let v:warningmsg = a:text
    echohl WarningMsg
    echomsg v:warningmsg
    echohl None
endfunction

function! ingo#msg#ErrorMsg( text )
    let v:errmsg = a:text
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None
endfunction

function! ingo#msg#MsgFromVimException()
    " v:exception contains what is normally in v:errmsg, but with extra
    " exception source info prepended, which we cut away.
    return substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
endfunction
function! ingo#msg#VimExceptionMsg()
    call ingo#msg#ErrorMsg(ingo#msg#MsgFromVimException())
endfunction
function! ingo#msg#CustomExceptionMsg( customPrefixPattern )
    call ingo#msg#ErrorMsg(substitute(v:exception, printf('^\%%(%s\):\s*', a:customPrefixPattern), '', ''))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
