" ingo/buffer/scratch/converted.vim: Functions for editing a converted buffer in a scratch duplicate.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#buffer#scratch#converted#Create( scratchFilename, ForwardConverter, BackwardConverter, windowOpenCommand, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Convert the current buffer via a:ForwardConverter into a scratch buffer
"   named a:scratchFilename that can be toggled back (via a:BackwardConverter)
"   and forth; writes update the original buffer.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   - Creates or opens scratch buffer and loads it in a window (as specified by
"     a:windowOpenCommand) and activates that window.
"   - Sets up autocmd, buffer-local mappings and commands.
"* INPUTS:
"   a:scratchFilename	The name for the scratch buffer.
"   a:ForwardConverter  Ex command or Funcref that converts the buffer contents.
"   a:BackwardConverter Ex command or Funcref that converts the buffer contents
"                       back to the original contents.
"   a:windowOpenCommand	Ex command to open the scratch window, e.g. :vnew or
"			:topleft new.
"   a:option.NextFilenameFuncref
"			    Funcref that is invoked (with a:filename) to
"			    generate file names for the generated buffer should
"			    the desired one (a:filename) already exist but not
"			    be a generated buffer.
"   a:option.toggleCommand  Name of a buffer-local command to toggle the scratch
"                           contents between original and converted formats.
"                           Defaults to :Toggle. No command is defined when an
"                           empty String is passed.
"   a:option.toggleMapping  Name of a buffer-local mapping to toggle the scratch
"                           contents between original and converted formats.
"                           Defaults to <CR>. No mapping is defined when an
"                           empty String is passed.
"   a:option.quitMapping    Name of a buffer-local mapping to exit the scratch
"                           buffer. Defaults to q.
"   a:option.isShowDiff     Flag whether the scratch buffer is diffed with the
"                           original buffer when it is toggled back. Default true.
"   a:option.isAllowUpdate  Flag whether :write can be used to update the
"                           original buffer. Default true.
"   Note: To handle errors caused by the initial conversion via
"   a:ForwardConverter, you need to put this method call into a try..catch block
"   and :bwipe the buffer when an exception is thrown.
"* RETURN VALUES:
"   Indicator whether the scratch buffer has been opened:
"   0	Failed to open scratch buffer.
"   1	Already in scratch buffer window.
"   2	Jumped to open scratch buffer window.
"   3	Loaded existing scratch buffer in new window.
"   4	Created scratch buffer in new window.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:NextFilenameFuncref = get(l:options, 'NextFilenameFuncref', '')
    let l:toggleCommand = get(l:options, 'toggleCommand', 'Toggle')
    let l:toggleMapping = get(l:options, 'toggleMapping', '<CR>')
    let l:quitMapping = get(l:options, 'quitMapping', 'q')
    let l:isShowDiff = get(l:options, 'isShowDiff', 1)
    let l:isAllowUpdate = get(l:options, 'isAllowUpdate', 1)

    let l:originalDiff = &l:diff
    let l:originalBufNr = bufnr('')
    let l:originalBuffer = ingo#window#switches#WinSaveCurrentBuffer(1)
    let g:ingo#buffer#scratch#converted#CreationContext = {
    \   'lines': getline(1, '$'),
    \   'Converter': a:ForwardConverter,
    \}
    if l:isShowDiff
	diffthis
    endif

    let l:status = call('ingo#buffer#scratch#CreateWithWriter',
    \   [a:scratchFilename,
    \   (l:isAllowUpdate ? function('ingo#buffer#scratch#converted#Writer') : ''),
    \   function('ingo#buffer#scratch#converted#Creator'),
    \   a:windowOpenCommand] +
    \   (empty(l:NextFilenameFuncref) ? [] : [l:NextFilenameFuncref])
    \)
    if l:status == 0
	let &l:diff = l:originalDiff    " The other participant isn't there, so undo enabling of diff mode.
	return l:status
    endif

    if ! empty(l:toggleCommand)
	execute printf('command! -buffer -bar %s if ! ingo#buffer#scratch#converted#Toggle() | echoerr ingo#err#Get() | endif', l:toggleCommand)
    endif
    if ! empty(l:toggleMapping)
	execute printf('nnoremap <buffer> <silent> %s :<C-u>if ! ingo#buffer#scratch#converted#Toggle()<Bar>echoerr ingo#err#Get()<Bar>endif<CR>', l:toggleMapping)
    endif
    if ! empty(l:quitMapping)
	if l:isShowDiff
	    " Restore the original buffer's diff mode.
	    execute printf('nnoremap <buffer> <silent> <nowait> %s :<C-u>let g:ingo#buffer#scratch#converted#record = b:IngoLibrary_scratch_converted<Bar>bwipe<Bar>call setbufvar(g:ingo#buffer#scratch#converted#record.originalBufNr, "&diff", g:ingo#buffer#scratch#converted#record.originalDiff)<Bar>unlet g:ingo#buffer#scratch#converted#record<CR>', l:quitMapping)
	else
	    execute printf('nnoremap <buffer> <silent> <nowait> %s :<C-u>bwipe<CR>', l:quitMapping)
	endif
    endif

    let b:IngoLibrary_scratch_converted = {
    \   'originalBufNr': l:originalBufNr,
    \   'originalBuffer': l:originalBuffer,
    \   'originalDiff': l:originalDiff,
    \   'isConverted': 1,
    \   'isShowDiff': l:isShowDiff,
    \   'ForwardConverter': a:ForwardConverter,
    \   'BackwardConverter': a:BackwardConverter,
    \}
    return l:status
endfunction
function! ingo#buffer#scratch#converted#Creator() abort
    call setline(1, g:ingo#buffer#scratch#converted#CreationContext.lines)
    call ingo#actions#ExecuteOrFunc(g:ingo#buffer#scratch#converted#CreationContext.Converter)
    unlet g:ingo#buffer#scratch#converted#CreationContext
endfunction
function! ingo#buffer#scratch#converted#Toggle() abort
    let l:isConverted = b:IngoLibrary_scratch_converted.isConverted
    let l:Converter = get(b:IngoLibrary_scratch_converted, l:isConverted ? 'BackwardConverter' : 'ForwardConverter')
    try
	call ingo#actions#ExecuteOrFunc(l:Converter)
	let b:IngoLibrary_scratch_converted.isConverted = ! l:isConverted

	if b:IngoLibrary_scratch_converted.isShowDiff
	    if l:isConverted
		diffthis
	    else
		diffoff
	    endif
	endif

	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! ingo#buffer#scratch#converted#Writer() abort
    let l:record = b:IngoLibrary_scratch_converted  " Need to save this here as we're switching buffers.
    let l:lines = getline(1, '$')

    let l:scratchTabNr = tabpagenr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1
    let l:scratchWinNr = winnr()
    try
	call ingo#window#switches#WinRestoreCurrentBuffer(l:record.originalBuffer, 1)
    catch /^WinRestoreCurrentBuffer:/
	try
	    execute l:record.originalBufNr . 'sbuffer'
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#err#SetVimException()
	    return 0
	endtry
    endtry

    let l:success = 1
    let l:save_lines = getline(1, '$')
    call ingo#lines#Replace(1, line('$'), l:lines)
    if l:record.isConverted
	" Need to convert back.
	try
	    call ingo#actions#ExecuteOrFunc(l:record.BackwardConverter)
	catch /^Vim\%((\a\+)\)\=:/
	    let l:success = 0
	    call ingo#err#SetVimException()

	    " Restore the original buffer contents.
	    call ingo#lines#Replace(1, line('$'), l:save_lines)

	    " Don't return yet, we still need to go back to the scratch buffer.
	endtry
    endif

    " Go back to the scratch buffer.
    if tabpagenr() != l:scratchTabNr
	execute l:scratchTabNr . 'tabnext'
    endif
    execute l:previousWinNr . 'wincmd w'
    execute l:scratchWinNr . 'wincmd w'

    setlocal nomodified " Contents have been persisted.
    return l:success
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
