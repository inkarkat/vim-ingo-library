" ingo/regexp/deconstruct.vim: Functions for taking apart regular expressions.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018-2019 Ingo Karkat
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

function! ingo#regexp#deconstruct#RemoveCharacterClasses( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Remove character classes (e.g. \d, \k), collections ([...]; unless they only
"   contain a single literal character), and optionally matched atoms from
"   a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with character classes removed.
"******************************************************************************
    let l:pattern = a:pattern

    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\_\?[iIkKfFpPsSdDxXoOwWhHaAlLuU]', "", 'g')

    " Optional sequence of atoms \%[]. Note: Because these can contain
    " collection-like stuff, it has to be processed before collections.
    let l:pattern = substitute(l:pattern, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%\[\(\%(\[\[\]\|\[\]\]\|[^][]\|' . ingo#regexp#collection#Expr({'isBarePattern': 1}) . '\)\+\)\]', '\1', 'g')

    let l:pattern = substitute(l:pattern, ingo#regexp#collection#Expr({'isCapture': 1}), '\=s:TransformCollection(submatch(1))', 'g')

    return l:pattern
endfunction
function! s:TransformCollection( characters ) abort
    return (a:characters =~# '^\\\?.$' ? matchstr(a:characters, '.$') : "\u2026")
endfunction

function! ingo#regexp#deconstruct#TranslateNumberEscapes( pattern ) abort
"******************************************************************************
"* PURPOSE:
"   Convert characters escaped as numbers from a:pattern.
"* ASSUMPTIONS / PRECONDITIONS:
"   Does not consider "very magic" (/\v)-style syntax. If you may have this,
"   convert via ingo#regexp#magic#Normalize() first.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pattern   regular expression
"* RETURN VALUES:
"   Modified a:pattern with numbered escapes translated to literal characters.
"******************************************************************************
    let l:pattern = a:pattern

    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%d\(\d\+\)', '\=nr2char(str2nr(submatch(1)))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%o\(\o\+\)', '\=nr2char(str2nr(submatch(1), 8))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%x\(\x\{1,2}\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%u\(\x\{1,4}\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')
    let l:pattern = substitute(l:pattern, '\C\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\%U\(\x\{1,8}\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')

    return l:pattern
endfunction

function! ingo#regexp#deconstruct#ToQuasiLiteral( pattern )
"******************************************************************************
"* PURPOSE:
"   Turn a:pattern into something resembling a literal match of it by removing
"   position atoms, multis, character classes / collections, and unescaping.
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
    let l:result = ingo#regexp#deconstruct#RemoveCharacterClasses(l:result)
    let l:result = ingo#regexp#deconstruct#TranslateNumberEscapes(l:result)
    return l:result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
