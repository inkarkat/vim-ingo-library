" ingo/regexp/atoms.vim: Functions around parsing pattern atoms.
"
" DEPENDENCIES:
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#atoms#PositionAtomExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any position atom.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\\\%([\^<>]\|_\^\|_\$\|%[\^$V#]\|%[<>]\?''.\|%[<>]\?\d\+[lcv]\)\|[\^$]\)'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
