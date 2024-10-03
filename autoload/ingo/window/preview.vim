" ingo/window/preview.vim: Functions for the preview window.
"
" DEPENDENCIES:
"
" Copyright: (C) 2008-2023 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#window#preview#OpenPreview( ... )
    " Note: We do not use :pedit to open the current file in the preview window,
    " because that command reloads the current buffer, which would fail (nobang)
    " / forcibly write (bang) it, and reset the current folds.
    "execute 'pedit! +' . escape( 'call setpos(".", ' . string(getpos('.')) . ')', ' ') . ' %'
    try
	" If the preview window is open, just go there.
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441:/
	" Else, temporarily open a dummy file. (There's no :popen command.)
	try
	    execute 'silent' (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '') (a:0 ? a:1 : '') 'pedit! +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile [No\ Name]'
	    wincmd P
	catch /^Vim\%((\a\+)\)\=:E36:/ " E36: Not enough room
	    " :pedit likely splits above the current window, but (depending on
	    " g:previewwindowsplitmode) it could split anywhere else. Try to
	    " locate windows with too little height and enlarge them (to the
	    " required minimum of 2 lines) until :pedit succeeds.
	    for l:winNr in [winnr() - 1] + filter(range(1, winnr('$')), 'v:val != winnr() - 1')
		try
		    if winheight(l:winNr) > 1
			continue " This window cannot be the problem.
		    endif

		    execute l:winNr . 'resize 2'
		    execute 'silent' (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '') (a:0 ? a:1 : '') 'pedit! +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile [No\ Name]'
		    wincmd P
		    return
		catch /^Vim\%((\a\+)\)\=:E36:/ " E36: Not enough room
		    continue
		endtry
	    endfor
	endtry
    endtry
endfunction
function! ingo#window#preview#OpenBuffer( bufnr, ... )
    if ! &l:previewwindow
	call ingo#window#preview#OpenPreview()
    endif

    " Load the passed buffer in the preview window, if it's not already there.
    if bufnr('') != a:bufnr
	silent execute a:bufnr . 'buffer'
    endif

    if a:0
	call cursor(a:1)
    endif
endfunction
function! ingo#window#preview#OpenNew()
    if ! &l:previewwindow
	call ingo#window#preview#OpenPreview()
    endif
    keepalt hide enew
endfunction
function! ingo#window#preview#OpenFilespec( filespec, ... )
    " Load the passed filespec in the preview window.
    let l:options = (a:0 ? a:1 : {})
    let l:isSilent = get(l:options, 'isSilent', 1)
    let l:isBang = get(l:options, 'isBang', 1)
    let l:prefixCommand = get(l:options, 'prefixCommand', '')
    let l:exFileOptionsAndCommands = get(l:options, 'exFileOptionsAndCommands', '')
    let l:cursor = get(l:options, 'cursor', [])
    if ! empty(l:cursor)
	let l:exFileOptionsAndCommands = (empty(l:exFileOptionsAndCommands) ? '+' : l:exFileOptionsAndCommands . '|') .
	\   printf('call\ cursor(%d,%d)', l:cursor[0], l:cursor[1])
    endif

    execute (l:isSilent ? 'silent' : '')
    \   (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '')
    \   l:prefixCommand
    \   'pedit' . (l:isBang ? '!' : '')
    \   l:exFileOptionsAndCommands
    \   ingo#compat#fnameescape(a:filespec)

    " XXX: :pedit uses the CWD of the preview window. If that already contains a
    " file with another CWD, the shortened command is wrong. Always use the
    " absolute filespec instead of shortening it via
    " fnamemodify(a:filespec, " ':~:.')
endfunction
function! ingo#window#preview#SplitToPreview( ... )
    if &l:previewwindow
	wincmd p
	if &l:previewwindow | return 0 | endif
    endif

    " Clone current cursor position to preview window (which now shows the same
    " file) or passed position.
    call ingo#window#preview#OpenBuffer(bufnr(''), (a:0 ? a:1 : getpos('.')[1:2]))
    return 1
endfunction
function! ingo#window#preview#GotoPreview()
    if &l:previewwindow | return | endif
    try
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441:/
	call ingo#window#preview#SplitToPreview()
    endtry
endfunction


function! ingo#window#preview#IsPreviewWindowVisible( ... )
    for l:winnr in range(1, winnr('$'))
	if (a:0 ?
	\   gettabwinvar(a:1, l:winnr, '&previewwindow') :
	\   getwinvar(l:winnr, '&previewwindow')
	\)
	    " There's still a preview window.
	    return l:winnr
	endif
    endfor

    return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
