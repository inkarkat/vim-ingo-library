" ingo/compat/fixes.vim: Workarounds for fixed bugs for earlier versions of Vim.
"
" DEPENDENCIES:
"
" Copyright: (C) 2026 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#compat#fixes#IsExclusiveSelectionVisualReselectOffByOne() abort
    " patch 9.0.1172: when 'selection' is "exclusive" then "1v" is one char short
    return (v:version < 900 || v:version == 900 && ! has('patch1172'))
    \   && visualmode() !=# 'V' && &selection ==# 'exclusive'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
