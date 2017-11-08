" ingo/compat/commands.vim: Command emulations for backwards compatibility with Vim versions that don't have these commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

"******************************************************************************
"* PURPOSE:
"   Return ':keeppatterns' if supported or an emulation of it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates internal command if emulation is needed.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Command. To use, turn >
"	command! -range Foo keeppatterns <line1>,<line2>substitute/\<...\>/FOO/g
"   <into >
"	command! -range Foo execute ingo#compat#commands#keeppatterns() '<line1>,<line2>substitute/\<...\>/FOO/g'
"******************************************************************************
if exists(':keeppatterns') == 2
    function! ingo#compat#commands#keeppatterns()
	return 'keeppatterns'
    endfunction
else
    if exists('ZzzzKeepPatterns') != 2
	command! -nargs=* ZzzzKeepPatterns execute <q-args> | call histdel('search', -1) | let @/ = histget('search', -1) | nohlsearch
    endif
    function! ingo#compat#commands#keeppatterns()
	return 'ZzzzKeepPatterns'
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
