" subs/BraceExpansion.vim: Generate arbitrary strings like in Bash.
"
" DEPENDENCIES:
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
    let l:text = a:text
    let l:previousText = 'X' . a:text

    let l:iterationCnt = 1
    while l:previousText !=# l:text
	let l:previousText = l:text
	let l:text = substitute(
	\   l:text,
	\   '\(.\{-}\)\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!{\(\%([^{}]\|\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\[{}]\)\+\)}',
	\   '\=submatch(1) . "\001<" . l:iterationCnt . "\001" . s:ProcessListInBraces(submatch(2), l:iterationCnt) . "\001" . l:iterationCnt . ">\001"',
	\   'g'
	\)
	let l:iterationCnt += 1
    endwhile

    return [l:iterationCnt - 2, l:text]
endfunction
function! s:ExpandOne( text, level )
    let l:parse = matchlist(a:text, printf('^\(.\{-}\)%s\(.\{-}\)%s\(.*\)$', "\001<" . a:level . "\001", "\001" . a:level . ">\001"))
    if empty(l:parse)
	return [a:text]
    endif

    let [l:pre, l:braceList, l:post] = l:parse[1:3]
    let l:braceElements = split(l:braceList, "\001" . a:level . ";\001", 1)

    if a:level > 1
	let l:braceElements = ingo#collections#Flatten1(map(l:braceElements, 's:ExpandOne(v:val, a:level - 1)'))
    endif

    return ingo#collections#Flatten1(map(l:braceElements, 's:ExpandOne(l:pre . v:val . l:post, a:level)'))
endfunction
function! subs#BraceExpansion#Do( text, ... )
    let l:joiner = (a:0 ? a:1 : ' ')

    let [l:nestingLevel, l:processedText] = s:ProcessBraces(a:text)

    let l:expansions = s:ExpandOne(l:processedText, l:nestingLevel)
    return join(l:expansions, l:joiner)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
