" ingo/subst/pairs.vim: Function to substitute wildcard=replacement pairs.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014-2026 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:pairPattern = '\(^[^=]\+\)=\(.*$\)'
function! s:SplitPair( pair, ... ) abort
    let l:options = (a:0 ? a:1 : {})
    let l:PatternTransformer = get(l:options, 'PatternTransformer', '')
    let l:ReplacementTransformer = get(l:options, 'ReplacementTransformer', '')

    if type(a:pair) == type([])
	let [l:from, l:to] = a:pair
    else
	if a:pair !~# s:pairPattern
	    throw 'Substitute: Not a substitution: ' . a:pair
	endif
	let [l:from, l:to] = matchlist(a:pair, s:pairPattern)[1:2]
    endif

    let l:pattern = ingo#regexp#fromwildcard#Convert(l:from)
    if ! empty(l:PatternTransformer)
	let l:pattern = call(l:PatternTransformer, [l:from, l:pattern])
    endif
    let l:replacement = l:to
    if ! empty(l:ReplacementTransformer)
	let l:replacement = call(l:ReplacementTransformer, [l:replacement])
    endif

    return [l:pattern, l:replacement]
endfunction
function! ingo#subst#pairs#Split( pairs, ... )
"******************************************************************************
"* PURPOSE:
"   Split {wildcard}={replacement} pairs into their regexp and replacement
"   parts.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:pairs: List of {wildcard}={replacement} pairs.
"   a:options.PatternTransformer:   Optional function to transform the wildcard;
"                                   invoked with the original wildcard and
"                                   converted pattern.
"   a:options.ReplacementTransformer:   Optional function to transform the
"                                       replacement; invoked with the
"                                       replacement.
"* RETURN VALUES:
"   List of [pattern, replacement] pairs.
"******************************************************************************
    return map(a:pairs, 'call("s:SplitPair", [v:val] + a:000)')
endfunction
function! ingo#subst#pairs#Substitute( text, pairs, ... )
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
"   a:isCanonicalizeReplacement Optional flag whether path separators in
"				{replacement} should be canonicalized. This is
"				important when doing further substitutions on
"				the result, but may be unwanted when wildcards
"				are treated as a convenient regexp-shorthand.
"				Default is false, no canonicalization.
"* RETURN VALUES:
"   List of [replacement, failedPairs], where failedPairs is a subset of
"   a:pairs.
"******************************************************************************
    let l:splitOptions = (a:0 && a:1 ? {'ReplacementTransformer': function('ingo#fs#path#Normalize')} : {})
    let l:replacement = a:text
    let l:failedPairs = []

    for l:pair in a:pairs
	let [l:from, l:to] = s:SplitPair(l:pair, l:splitOptions)
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
