" ingo/compat/mapping.vim: Compatibility functions for defining mappings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

"******************************************************************************
"* PURPOSE:
"   After fixing https://github.com/vim/vim/issues/6163 (In the GUI can't
"   distinguish "<M-v>" from "ö" in a mapping), mappings that use a combination
"   of Alt and Shift and a non-alphabetic character (e.g. Alt + Shift + /) have
"   to be defined as <A-S-?> instead of <A-?>.
"   Unfortunately, adding the modifier makes these mappings incompatible with
"   non-GTK (e.g. Windows) and older GVIM versions (so this might actually be an
"   accidental regression), therefore we need a conditional.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   The appropriate modifier (or nothing). Use in combination with :execute (and
"   printf()):
"       execute printf('nmap <A-%s?> <Plug>(Foo)', ingo#compat#mapping#MetaShift())
"******************************************************************************
if has('gui_gtk') && (v:version == 802 && has('patch851') || v:version > 802)
    function! ingo#compat#mapping#MetaShift() abort
	return 'S-'
    endfunction
else
    function! ingo#compat#mapping#MetaShift() abort
	return ''
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
