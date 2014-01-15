" ingo/subst/tuples.vim: Function to substitute wildcard=replacement tuples.
"
" DEPENDENCIES:
"   - ingo/regexp/fromwildcard.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.016.001	16-Jan-2014	file creation from
"				autoload/EditSimilar/Substitute.vim

let s:tuplePattern = '\(^.\+\)=\(.*$\)'
function! s:TupleToPair( tuple )
    if a:tuple !~# s:tuplePattern
	throw 'Substitute: Not a substitution: ' . a:tuple
    endif
    let [l:from, l:to] = matchlist(a:tuple, s:tuplePattern)[1:2]
    return [ingo#regexp#fromwildcard#Convert(l:from), l:to]
endfunction
function! ingo#subst#tuples#GetPairs( tuples )
    return map(a:tuples, 's:TupleToPair(v:val)')
endfunction
function! ingo#subst#tuples#Substitute( text, tuples )
"******************************************************************************
"* PURPOSE:
"   Apply {wildcard}={replacement} tuples (modeled after the Korn shell's "cd
"   {old} {new}" command).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text      Text to be substituted.
"   a:tuples    List of {wildcard}={replacement} Strings that should be applied
"		to a:text.
"* RETURN VALUES:
"   List of [replacement, failedTuples], where failedTuples is a subset of
"   a:tuples.
"******************************************************************************
    let l:replacement = a:text
    let l:failedTuples = []

    for l:tuple in a:tuples
	let [l:from, l:to] = s:TupleToPair(l:tuple)
	let l:beforeReplacement = l:replacement
	let l:replacement = substitute(l:replacement, l:from, escape(l:to, '\&~'), 'g')
	if l:replacement ==# l:beforeReplacement
	    call add(l:failedTuples, l:tuple)
	endif
"***D echo '****' (l:beforeReplacement =~ ingo#regexp#fromwildcard#Convert(l:from) ? '' : 'no ') . 'match for tuple' ingo#regexp#fromwildcard#Convert(l:from)
"***D echo '**** replacing' l:beforeReplacement "\n          with" l:replacement
    endfor

    return [l:replacement, l:failedTuples]
endfunction
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
