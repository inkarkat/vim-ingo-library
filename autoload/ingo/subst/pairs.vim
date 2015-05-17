" ingo/subst/pairs.vim: Function to substitute wildcard=replacement pairs.
"
" DEPENDENCIES:
"   - ingo/fs/path.vim autoload script
"   - ingo/regexp/fromwildcard.vim autoload script
"
" Copyright: (C) 2014-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.003	01-May-2015	Canonicalize path separators in {replacement},
"				too. This is important to match further pairs,
"				too, as the pattern is always in canonical form,
"				so the replacement has to be, too.
"				ENH: Allow passing to [wildcard, replacement]
"				Lists instead of {wildcard}={replacement}
"				Strings, too.
"   1.016.002	17-Jan-2014	Change s:pairPattern so that the first, not the
"				last = is used as the pair delimiter.
"   1.016.001	16-Jan-2014	file creation from
"				autoload/EditSimilar/Substitute.vim

let s:pairPattern = '\(^[^=]\+\)=\(.*$\)'
function! s:SplitPair( pair )
    if type(a:pair) == type([])
	let [l:from, l:to] = a:pair
    else
	if a:pair !~# s:pairPattern
	    throw 'Substitute: Not a substitution: ' . a:pair
	endif
	let [l:from, l:to] = matchlist(a:pair, s:pairPattern)[1:2]
    endif
    return [ingo#regexp#fromwildcard#Convert(l:from), ingo#fs#path#Normalize(l:to)]
endfunction
function! ingo#subst#pairs#Split( pairs )
    return map(a:pairs, 's:SplitPair(v:val)')
endfunction
function! ingo#subst#pairs#Substitute( text, pairs )
"******************************************************************************
"* PURPOSE:
"   Apply {wildcard}={replacement} pairs (modeled after the Korn shell's "cd
"   {old} {new}" command).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be substituted.
"   a:pairs List of {wildcard}={replacement} Strings that should be applied to
"	    a:text. Or List of [wildcard, replacement] List elements.
"* RETURN VALUES:
"   List of [replacement, failedPairs], where failedPairs is a subset of
"   a:pairs.
"******************************************************************************
    let l:replacement = a:text
    let l:failedPairs = []

    for l:pair in a:pairs
	let [l:from, l:to] = s:SplitPair(l:pair)
	let l:beforeReplacement = l:replacement
	let l:replacement = substitute(l:replacement, l:from, escape(l:to, '\&~'), 'g')
	if l:replacement ==# l:beforeReplacement
	    call add(l:failedPairs, l:pair)
	endif
"***D echo '****' (l:beforeReplacement =~ ingo#regexp#fromwildcard#Convert(l:from) ? '' : 'no ') . 'match for pair' ingo#regexp#fromwildcard#Convert(l:from)
"***D echo '**** replacing' l:beforeReplacement "\n          with" l:replacement
    endfor

    return [l:replacement, l:failedPairs]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
