" subs/BraceExpansion.vim: Generate arbitrary strings like in Bash.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/collections/fromsplit.vim autoload script
"   - ingo/escape.vim autoload script
"
" Copyright: (C) 2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	30-Nov-2016	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:ProcessListInBraces( bracesText, iterationCnt )
    return ingo#escape#Unescape(substitute(a:bracesText, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!,', "\001" . a:iterationCnt . ";\001", "g"), ',')
endfunction
function! s:ProcessBraces( text )
    " We need to process nested braces from the outside to the inside;
    " unfortunately, with regexp parsing, we cannot skip over inner matching
    " braces. To work around that, we process all braces from the inside out,
    " and translate them into special tokens: ^A<N^A ... ^AN;^A ... ^AN>^A,
    " where ^A is 0x01 (hopefully not occurring as this token in the text), N is
    " the nesting level (1 = innermost), and < ; > are the substitutes for { , }
    let l:text = a:text
    let l:previousText = 'X' . a:text   " Make this unequal to the current one, handle empty string.

    let l:iterationCnt = 1
    while l:previousText !=# l:text
	let l:previousText = l:text
	let l:text = substitute(
	\   l:text,
	\   '\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!{\(\%([^{}]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[{}]\)*,\%([^{}]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[{}]\)*\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!}',
	\   '\=submatch(1) . "\001<" . l:iterationCnt . "\001" . s:ProcessListInBraces(submatch(2), l:iterationCnt) . "\001" . l:iterationCnt . ">\001"',
	\   'g'
	\)
	let l:iterationCnt += 1
    endwhile

    return [l:iterationCnt - 2, l:text]
endfunction
function! s:ExpandOneLevel( text, level )
    let l:parse = matchlist(a:text, printf('^\(.\{-}\)%s\(.\{-}\)%s\(.*\)$', "\001<" . a:level . "\001", "\001" . a:level . ">\001"))
    if empty(l:parse)
	return (a:level > 1 ?
	\   s:ExpandOneLevel(a:text, a:level - 1) :
	\   [a:text]
	\)
    endif

    let [l:pre, l:braceList, l:post] = l:parse[1:3]
    let l:braceElements = split(l:braceList, "\001" . a:level . ";\001", 1)

    if a:level > 1
	let l:braceElements = ingo#collections#Flatten1(map(l:braceElements, 's:ExpandOneLevel(v:val, a:level - 1)'))
    endif

    return ingo#collections#Flatten1(map(l:braceElements, 's:ExpandOneLevel(l:pre . v:val . l:post, a:level)'))
endfunction
function! subs#BraceExpansion#ExpandWord( word, joiner )
    let [l:nestingLevel, l:processedText] = s:ProcessBraces(a:word)
    let l:expansions = s:ExpandOneLevel(l:processedText, l:nestingLevel)
    call map(l:expansions, 'ingo#escape#Unescape(v:val, "\\{}")')
    return join(l:expansions, a:joiner)
endfunction
function! subs#BraceExpansion#Do( text, ... )
"******************************************************************************
"* PURPOSE:
"	Expand "foo{x,y}" inside a:text to "foox fooy", like Bash's brace
"	expansion.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Source text with braces.
"   a:joiner    Literal text to be used to join the expanded expressions;
"		defaults to a <Space> character.
"   a:braceSeparatorPattern Regular expression to separate the expressions where
"			    braces are expanded; defaults to a:joiner or
"			    any whitespace.
"* RETURN VALUES:
"   a:text, separated by a:braceSeparatorPattern, each part had brace
"   expressions expanded, then joined by a:joiner, and all put together again.
"******************************************************************************
    let l:joiner = (a:0 ? a:1 : ' ')
    let l:braceSeparatorPattern = (a:0 >= 2 ? a:2 : (a:0 ? '\V' . escape(l:joiner, '\') : '\_s\+'))

    let l:result = ingo#collections#fromsplit#MapItems(
    \   a:text,
    \   '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!' . l:braceSeparatorPattern,
    \   printf('subs#BraceExpansion#ExpandWord(ingo#escape#UnescapeExpr(v:val, %s), %s)', string(l:braceSeparatorPattern), string(l:joiner))
    \)

    return join(l:result, '')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
