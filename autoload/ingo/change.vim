" ingo/change.vim: Functions around the last changed text.
"
" DEPENDENCIES:
"   - ingo/text.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#change#Get()
"******************************************************************************
"* PURPOSE:
"   Get the last inserted / changed text (between marks '[,']).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Last changed text, or empty string if there was no change yet or the last
"   change was a deletion.
"******************************************************************************
    let [l:startPos, l:endPos] = [getpos("'[")[1:2], getpos("']")[1:2]]

    " If the change was an insertion, the end of change mark is set _after_ the
    " last inserted character. For other changes (e.g. gU), the end of change
    " mark is _on_ the last changed character. We need to compare with register
    " . contents.
    let l:lastInsertedText = ingo#text#Get(l:startPos, l:endPos, 1)
    if l:lastInsertedText ==# @.
	return l:lastInsertedText
    endif

    let l:lastChangedText = ingo#text#Get(l:startPos, l:endPos, 0)
    return l:lastChangedText
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
