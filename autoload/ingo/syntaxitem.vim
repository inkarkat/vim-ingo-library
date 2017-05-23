" ingo/syntaxitem.vim: Functions for retrieving information about syntax items.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"
" Copyright: (C) 2011-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.030.002	24-May-2017	ingo#syntaxitem#IsOnSyntax(): Factor out
"				synstack() emulation into ingo#compat#synstack()
"				and unify similar function variants.
"   1.005.001	02-May-2013	file creation

function! ingo#syntaxitem#IsOnSyntax( pos, syntaxItemPattern )
    " Taking the example of comments:
    " Other syntax groups (e.g. Todo) may be embedded in comments. We must thus
    " check whole stack of syntax items at the cursor position for comments.
    " Comments are detected via the translated, effective syntax name. (E.g. in
    " Vimscript, "vimLineComment" is linked to "Comment".)
    for l:id in reverse(ingo#compat#synstack(a:pos[1], a:pos[2]))
	let l:actualSyntaxItemName = synIDattr(l:id, 'name')
	let l:effectiveSyntaxItemName = synIDattr(synIDtrans(l:id), 'name')
"****D echomsg '****' l:actualSyntaxItemName . '->' . l:effectiveSyntaxItemName
	if l:actualSyntaxItemName =~# a:syntaxItemPattern || l:effectiveSyntaxItemName =~# a:syntaxItemPattern
	    return 1
	endif
    endfor
    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
