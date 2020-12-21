" ingo/hlgroup.vim: Functions around highlight groups.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#hlgroup#LinksTo( name )
    return synIDattr(synIDtrans(hlID(a:name)), 'name')
endfunction

function! ingo#hlgroup#GetColor( isBackground, syntaxId, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Get the foreground / background color of a:syntaxId [in a:mode], considering
"   the effect of a set "reverse" attribute.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isBackground  Flag whether the background color should be returned.
"   a:syntaxId      Syntax ID, to be obtained via hlID().
"   a:mode          Optional UI color mode.
"* RETURN VALUES:
"   Color name / RGB color in GUI mode.
"******************************************************************************
    let l:mode = (a:0 ? a:1 : '')
    let l:attributes = ['fg', 'bg']
    if a:isBackground | call reverse(l:attributes) | endif
    if synIDattr(synIDtrans(a:syntaxId), 'reverse', l:mode) | call reverse(l:attributes) | endif

    return synIDattr(synIDtrans(a:syntaxId), l:attributes[0] . (l:mode ==# 'gui' ? '#' : ''), l:mode)    " Note: Use RGB comparison for GUI mode to account for the different ways of specifying the same color.
endfunction
function! ingo#hlgroup#GetForegroundColor( syntaxId, ... ) abort
    return call('ingo#hlgroup#GetColor', [0, a:syntaxId] + a:000)
endfunction
function! ingo#hlgroup#GetBackgroundColor( syntaxId, ... ) abort
    return call('ingo#hlgroup#GetColor', [1, a:syntaxId] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
