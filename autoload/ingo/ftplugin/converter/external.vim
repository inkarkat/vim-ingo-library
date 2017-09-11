" ingo/ftplugin/converter/external.vim: Build a file converter via an external command.
"
" DEPENDENCIES:
"   - ingo/buffer/scratch.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/format.vim autoload script
"   - ingo/ftplugin/converter/external.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:ObtainText( externalCommandVariable, commandLineFormat, filespec )
    execute 'let l:externalCommand =' a:externalCommandVariable
    if empty(l:externalCommand)
	call ingo#err#Set(printf('The converter is not configured in %s.', a:externalCommandVariable))
	return []
    endif

    let l:command = call('ingo#format#Format', [a:commandLineFormat] + map([l:externalCommand, expand(a:filespec)], 'ingo#compat#shellescape(v:val)'))
    let l:result = ingo#compat#systemlist(l:command)
    if v:shell_error != 0
	call ingo#err#Set('Conversion failed: shell returned ' . v:shell_error . (empty(l:result) ? '' : ': ' . join(l:result)))
	return []
    endif

    return l:result
endfunction
function! ingo#ftplugin#converter#external#ToText( externalCommandVariable, commandLineFormat, filespec )
    let l:text = s:ObtainText(a:externalCommandVariable, a:commandLineFormat, a:filespec)
    if empty(l:text)
	return 0
    endif

    silent %delete _
    setlocal endofline nobinary fileencoding<
    call setline(1, l:text)
    call setpos("'[", [0, 1, 1, 0])
    call setpos("']", [0, line('$'), 1, 0])
    setlocal nomodifiable nomodified
    return 1
endfunction
function! ingo#ftplugin#converter#external#ExtractText( externalCommandVariable, commandLineFormat, fileExtension, mods, filespec )
    let l:text = s:ObtainText(a:externalCommandVariable, a:commandLineFormat, a:filespec)
    if empty(l:text)
	return 0
    endif

    let l:status = ingo#buffer#scratch#Create('', expand('%:r') . '.' . a:fileExtension, 1, l:text, (empty(a:mods) ? 'enew' : a:mods . ' new'))
    if l:status == 0
	call ingo#err#Set('Failed to open scratch buffer.')
	return 0
    endif
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
