" ingo/version.vim: Meta-function for plugin dependency check.
"
" DEPENDENCIES:
"
" Copyright: (C) 2024-2025 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:version = '1.047'

"******************************************************************************
"* PURPOSE:
"   Called by plugins to check for existence and supported version of the
"   ingo-library.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Throws 'ingo-library: ...' exception if version requirements aren't met.
"   Vim throws 'E117: Unknown function' if the ingo-library isn't installed at
"   all.
"* INPUTS:
"   a:wantedVersion String of the minimum required version.
"* RETURN VALUES:
"   Succeeds if the version requirements are met.
"* USAGE:
"   Put this at the top of the plugin's main autoload script (so that it gets
"   triggered on first use of a plugin command or mapping):
"   try
"       call ingo#version#Has('1.000')
"   catch /^ingo-library:/
"       echoerr v:exception
"   catch /^Vim\%((\a\+)\)\=:/
"       echoerr printf('The ingo-library dependency is missing; see :help %s-dependencies', expand('<sfile>:t:r'))
"   endtry
"******************************************************************************
function! ingo#version#Has( wantedVersion ) abort
    let l:currentVersion = split(s:version, '\.')
    let l:wantedVersion = split(a:wantedVersion, '\.')
    for l:i in range(len(l:currentVersion))
	if l:i == 0 && str2nr(l:currentVersion[l:i]) != str2nr(get(l:wantedVersion, l:i, '0'))
	    throw printf('ingo-library: Incompatible major version installed; you have %s, plugin wants %s', join(l:currentVersion, '.'), join(l:wantedVersion, '.'))
	elseif str2nr(l:currentVersion[l:i]) < str2nr(get(l:wantedVersion, l:i, '0'))
	    throw printf('ingo-library: Installed version is too old; you have %s, plugin wants %s', join(l:currentVersion, '.'), join(l:wantedVersion, '.'))
	endif
    endfor
    return 0
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
