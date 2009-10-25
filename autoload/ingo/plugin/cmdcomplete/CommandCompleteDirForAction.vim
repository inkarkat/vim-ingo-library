
let s:count = 0
 
function! s:GlobFilenames( filespecWildcard )
    return map(split(glob(a:filespecWildcard), "\n"), 'fnamemodify(v:val, ":t")')
endfunction
function! s:CompleteFiles( title, dirspec, wildignore, argLead )
    let l:files = s:GlobFilenames(a:dirspec . a:argLead)
    if len(l:files) == 1 && filereadable(a:dirspec . l:files[0])
	return l:files
    endif

    let l:filespecWildcard = a:dirspec . a:argLead . '*'
    let l:files = s:GlobFilenames(l:filespecWildcard)
    return l:files
endfunction
function! s:CommandCompleteDirForAction( command, action, title, dirspec, wildignore )
    let s:count += 1
    execute 
    \ printf("function! CompleteDir%s(ArgLead, CmdLine, CursorPos)\n", s:count) . 
    \ printf("    return s:CompleteFiles('%s', '%s', '%s', a:ArgLead)\n", a:title, a:dirspec, a:wildignore) .
    \        "endfunction"
    
    execute printf('command! -bar -nargs=1 -complete=customlist,CompleteDir%s %s %s %s<args>', s:count, a:command, a:action, a:dirspec)
endfunction

call s:CommandCompleteDirForAction( 'TestCommand', 'split', 'title', 'e:/a/ablage/', '')

