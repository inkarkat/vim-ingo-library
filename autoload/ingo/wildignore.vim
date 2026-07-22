" ingo/wildignore.vim: Functions around the wildignore option.
"
" DEPENDENCIES:
"
" Copyright: (C) 2026 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#wildignore#ExecuteWithout( excommand, filespecs )
"*******************************************************************************
"* PURPOSE:
"   Executes a:excommand with all a:filespecs passed as arguments while
"   'wildignore' is temporarily  disabled. This allows to introduce filespecs to
"   the argument list (:args ..., :argadd ...) which would normally be filtered
"   by 'wildignore'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:excommand	    Ex command to be invoked
"   a:filespecs	    List of filespecs.
"* RETURN VALUES:
"   none
"*******************************************************************************
    let l:save_wildignore = &wildignore
    set wildignore=
    try
	execute a:excommand join(map(copy(a:filespecs), 'ingo#compat#fnameescape(v:val)'), ' ')
    finally
	let &wildignore = l:save_wildignore
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
