" ingo/selection/virtcols.vim: Functions for defining a visual selection based on virtual columns.
"
" DEPENDENCIES:
"   - ingo/cursor.vim autoload script
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#selection#virtcols#Get()
"******************************************************************************
"* PURPOSE:
"   Get a selectionObject that contains information about the cell-based,
"   virtual screen columns that the current visual selection occupies.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   a:selection object
"******************************************************************************
    return {'mode': visualmode(), 'startLnum': line("'<"), 'startVirtCol': virtcol("'<"), 'endLnum': line("'>"), 'endVirtCol': virtcol("'>")}
endfunction

function! ingo#selection#virtcols#DefineAndExecute( selectionObject, command )
"******************************************************************************
"* PURPOSE:
"   Set / restore the visual selection based on the passed a:selectionObject and
"   execute a:command on it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets the visual selection.
"   Executes a:command.
"* INPUTS:
"   a:selectionObject   Obtained from ingo#selection#virtcols#Get().
"   a:command           Ex command to work on the visual selection, e.g.
"			'normal! y' to yank the contents.
"* RETURN VALUES:
"   None.
"******************************************************************************
    call ingo#cursor#Set(a:selectionObject.startLnum, a:selectionObject.startVirtCol)
    execute 'normal!' a:selectionObject.mode
    call ingo#cursor#Set(a:selectionObject.endLnum, a:selectionObject.endVirtCol)
    execute a:command
endfunction
function! ingo#selection#virtcols#Set( selectionObject )
"******************************************************************************
"* PURPOSE:
"   Set / restore the visual selection based on the passed a:selectionObject.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Sets the visual selection.
"* INPUTS:
"   a:selectionObject   Obtained from ingo#selection#virtcols#Get().
"* RETURN VALUES:
"   None.
"******************************************************************************
    call ingo#selection#virtcols#DefineAndExecute(a:selectionObject, "normal! \<Esc>")
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
