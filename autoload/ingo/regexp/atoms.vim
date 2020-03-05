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

function! ingo#regexp#atoms#NumberEscapesExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any numbered escape; i.e. \%d; cp.
"   |E678|.
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%\%(d\%(\d\+\)\|o\%(\o\+\)\|x\%(\x\{1,2}\)\|u\%(\x\{1,4}\)\|U\%(\x\{1,8}\)\)'
endfunction

function! ingo#regexp#atoms#BranchesExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any branch atoms: \%(, \(, \|, \).
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
    return '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(%\?(\|[|)]\)'
endfunction

function! ingo#regexp#atoms#OtherAtomExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any non-ordinary (i.e. not a
"   literal character) atom that isn't already matched by one of the other atom
"   expressions here.
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
    return '^\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%#=[012]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\%(zs\|ze\|[&etrbn123456789cCzmMvV]\|\)'
endfunction

function! ingo#regexp#atoms#NonOrdinaryAtomExpr() abort
"******************************************************************************
"* PURPOSE:
"   Return a regular expression that matches any non-ordinary (i.e. not a
"   literal character) atom, such as branches, multis, positions, collections,
"   escapes.
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
    return join([
    \   ingo#regexp#atoms#BranchesExpr(),
    \   ingo#regexp#multi#Expr(),
    \   ingo#regexp#atoms#PositionAtomExpr(),
    \   ingo#regexp#collection#Expr(),
    \   ingo#regexp#atoms#NumberEscapesExpr(),
    \   ingo#regexp#atoms#OtherAtomExpr()
    \], '\|')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
