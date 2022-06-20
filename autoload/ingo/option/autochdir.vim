" ingo/option/autochdir.vim: Functions around the autochdir option.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if exists('+autochdir')
    function! ingo#option#autochdir#Disable() abort
"******************************************************************************
"* PURPOSE:
"   Turn off automatic change of the current working directory to the current
"   buffer's file ('autochdir').
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Unsets 'autochdir'.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   1 if the option actually turned from on to off, else 0.
"******************************************************************************
	if &autochdir
	    set noautochdir
	    return 1
	endif
	return 0
    endfunction

    function! ingo#option#autochdir#Restore( isEnable ) abort
"******************************************************************************
"* PURPOSE:
"   Re-enable the automatic change of the current working directory to the
"   current buffer's file.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes 'autochdir'.
"* INPUTS:
"   a:isEnable  Flag (typically return value from
"               ingo#option#autochdir#Disable()) whether the option should be
"               enabled or disabled.
"               If not a Boolean / Number, nothing is done. So you can pass []
"               or v:null as a no-op value.
"* RETURN VALUES:
"   1 if the option actually got changed, else 0.
"******************************************************************************
	if type(a:isEnable) == type(0)
	    let &autochdir = a:isEnable
	    return a:isEnable
	else
	    return 0
	endif
    endfunction
else
    function! ingo#option#autochdir#Disable() abort
	return 0
    endfunction
    function! ingo#option#autochdir#Restore( isEnable ) abort
	return 0
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
