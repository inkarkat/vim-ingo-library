" ingo/regexp/deconstruct.vim: Functions for taking apart regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#regexp#deconstruct#RemovePositionAtoms( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove atoms that assert a certain position of the pattern (like ^, $, \<,
"   \%l) from a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with position atoms removed.
"******************************************************************************
    return substitute(a:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(\\\%([\^<>]\|_\^\|_\$\|%[\^$V#]\|%[<>]\?''.\|%[<>]\?\d\+[lcv]\)\|[\^$]\)', '', 'g')
endfunction

function! ingo#regexp#deconstruct#RemoveMultis( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove multi items (*, \+, etc.) that signify the multiplicity of the
"   previous atom from a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with multi items removed.
"******************************************************************************
    return substitute(a:pattern, ingo#regexp#multi#Expr(), '', 'g')
endfunction

let s:specialLookup = {
\   'e': "\e",
\   't': "\t",
\   'r': "\r",
\   'b': "\b",
\   'n': "\n",
\}
function! ingo#regexp#deconstruct#UnescapeSpecialCharacters( pattern )
"******************************************************************************
"* PURPOSE:
"   Remove the backslash in front of characters that have special regular
"   expression meaning without it, like [\.*~], and interpret special sequences
"   like \e \t \n.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with special characters turned into literal ones.
"******************************************************************************
    let l:result = a:pattern
    let l:result = substitute(l:result, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\([etrbn]\)', '\=s:specialLookup[submatch(1)]', 'g')
    let l:result = ingo#escape#Unescape(l:result, '\^$.*~[]')
    return l:result
endfunction

function! ingo#regexp#deconstruct#ToQuasiLiteral( pattern )
"******************************************************************************
"* PURPOSE:
"   Turn a:pattern into something resembling a literal match of it by removing
"   position atoms, multis, and unescaping.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern that resembles a literal match.
"******************************************************************************
    let l:result = a:pattern
    let l:result = ingo#regexp#deconstruct#RemovePositionAtoms(l:result)
    let l:result = ingo#regexp#deconstruct#RemoveMultis(l:result)
    let l:result = ingo#regexp#deconstruct#UnescapeSpecialCharacters(l:result)
    return l:result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
