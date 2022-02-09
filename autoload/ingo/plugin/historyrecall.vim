" ingo/plugin/historyrecall.vim: Functions for providing recall from a history of values.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:historySources = {}
let s:namedSources = {}
let s:recallsSources = {}
let s:Callbacks = {}
let s:recalledIdentities = {}
let s:lastHistories = {}

function! ingo#plugin#historyrecall#Register( what, historySource, namedSource, recallsSource, Callback ) abort
    let s:historySources[a:what] = a:historySource
    let s:namedSources[a:what] = a:namedSource
    let s:recallsSources[a:what] = a:recallsSource
    let s:Callbacks[a:what] = a:Callback
endfunction

function! s:HasName( register ) abort
    return (a:register !=# ingo#register#Default())
endfunction
function! ingo#plugin#historyrecall#RecallRepeat( what, count, repeatCount, register )
    let l:isOverriddenCount = (a:repeatCount > 0 && a:repeatCount != g:repeat_count)
    let l:isOverriddenRegister = (g:repeat_reg[1] !=# a:register)

    if l:isOverriddenRegister
	" Reset the count if the actual register differs from the original
	" register, as count may be the last from history number or the
	" multiplier.
	return ingo#plugin#historyrecall#Recall(a:what, 1, 0, a:register)
    elseif l:isOverriddenCount
	" An overriding count (without a register) selects the previous
	" [count]'th history item for repeat.
	return ingo#plugin#historyrecall#Recall(a:what, a:count, a:repeatCount, ingo#register#Default())
    else
	return ingo#plugin#historyrecall#Recall(a:what, a:count, a:repeatCount, a:register)
    endif
endfunction
function! ingo#plugin#historyrecall#Recall( what, count, repeatCount, register )
    if ! s:HasName(a:register)
	if len(s:historySources[a:what]) == 0
	    call ingo#err#Set(printf('No %ss yet', a:what))
	    return 0
	elseif len(s:historySources[a:what]) < a:count
	    call ingo#err#Set(printf('There %s only %d %s%s in the history',
	    \   len(s:historySources[a:what]) == 1 ? 'is' : 'are',
	    \   len(s:historySources[a:what]),
	    \   a:what,
	    \   len(s:historySources[a:what]) == 1 ? '' : 's'
	    \))
	    return 0
	endif

	let l:multiplier = 1
	let s:lastHistories[a:what] = s:historySources[a:what][a:count - 1]
	let l:recallIdentity = (a:count - 1) . "\n" . s:lastHistories[a:what]
    elseif a:register =~# '[1-9]'
	let l:index = str2nr(a:register) - 1
	if len(s:recallsSources[a:what]) == 0
	    call ingo#err#Set(printf('No recalled %ss yet', a:what))
	    return 0
	elseif len(s:recallsSources[a:what]) <= l:index
	    call ingo#err#Set(printf('There %s only %d recalled %s%s',
	    \   len(s:recallsSources[a:what]) == 1 ? 'is' : 'are',
	    \   len(s:recallsSources[a:what]),
	    \   a:what,
	    \   len(s:recallsSources[a:what]) == 1 ? '' : 's'
	    \))
	    return 0
	endif

	let l:multiplier = a:count
	let s:lastHistories[a:what] = s:recallsSources[a:what][l:index]
	let l:recallIdentity = '"' . a:register . "\n" . s:lastHistories[a:what]
	if a:register ==# '1'
	    " Put any recall other that the last recall itself back at the top,
	    " even if the last recall was the same one.
	    " This creates a "cycling" effect so that one can use "3q<A-a> or
	    " q<C-a>"3 to recall the third-to-last element, and subsequent
	    " repeats will recall the second-to-last, last, and then again
	    " 3-2-1-3-2-1-...
	    let s:recalledIdentities[a:what] = ''
	endif
    elseif has_key(s:namedSources[a:what], a:register)
	let l:multiplier = a:count
	let s:lastHistories[a:what] = s:namedSources[a:what][a:register]
	let l:recallIdentity = '"' . a:register . "\n" . s:lastHistories[a:what]
    else
	call ingo#err#Set(a:register =~# '[a-zA-Z]' ?
	\   printf('Nothing named "%s yet', a:register) :
	\   printf('Not a valid name: "%s; must be {a-zA-Z} or {1-9}', a:register)
	\)
	return 0
    endif

    call s:Recall(a:what, l:recallIdentity, a:repeatCount, a:register, l:multiplier)
    return 1
endfunction
function! s:Recall( what, recallIdentity, repeatCount, register, multiplier )
    if ! empty(a:recallIdentity) && a:recallIdentity !=# s:recalledIdentities[a:what]
	" It's not a repeat of the last recalled thing; put it at the first
	" position of the recall stack.
	call insert(s:recallsSources[a:what], s:lastHistories[a:what])
	if len(s:recallsSources[a:what]) > 9
	    call remove(s:recallsSources[a:what], 9, -1)
	endif
	let s:recalledIdentities[a:what] = a:recallIdentity
    endif

    call call(s:Callbacks[a:what], [s:lastHistories[a:what], a:multiplier, a:repeatCount, a:register])
endfunction
function! ingo#plugin#historyrecall#List( what, multiplier, register )
    let l:validNames = filter(
    \   split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs'),
    \   'has_key(s:namedSources[a:what], v:val)'
    \)
    let l:recalledNum = len(s:recallsSources[a:what])

    if len(s:historySources[a:what]) + len(l:validNames) + l:recalledNum == 0
	call ingo#err#Set(printf('No %ss yet', a:what))
	return 0
    endif

    let l:hasName = s:HasName(a:register)
    echohl Title
    echo ' #  ' . a:what
    echohl None
    for l:i in range(1, l:recalledNum)
	echo '"' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(s:recallsSources[a:what][l:i - 1])
    endfor
    for l:i in l:validNames
	echo '"' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(s:namedSources[a:what][l:i])
    endfor
    for l:i in range(min([9, len(s:historySources[a:what])]), 1, -1)
	echo ' ' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(s:historySources[a:what][l:i - 1])
    endfor

    let l:validNamesAndRecalls = join(l:validNames, '') . join(range(1, l:recalledNum), '')
    echo printf('Type number%s (<Enter> cancels) to insert%s: ', (empty(l:validNamesAndRecalls) ? '' : ' or "{name}'), (l:hasName ? ' and assign to "' . a:register : ''))
    let l:choice = ingo#query#get#ValidChar({'validExpr': "[123456789\<CR>" . (empty(l:validNamesAndRecalls) ? '' : '"' . l:validNamesAndRecalls) . ']'})
    let l:recallIdentity = ''
    let l:repeatCount = a:multiplier
    if empty(l:choice) || l:choice ==# "\<CR>"
	return 1
    elseif l:choice ==# '"'
	let l:choice = ingo#query#get#ValidChar({'validExpr': "[\<CR>" . l:validNamesAndRecalls . ']'})
	if empty(l:choice) || l:choice ==# "\<CR>"
	    return 1
	elseif l:choice =~# '\d'
	    let s:lastHistories[a:what] = s:recallsSources[a:what][str2nr(l:choice) - 1]
	    let l:repeatCount = str2nr(l:choice)    " Counting last added to history here.
	    let l:repeatRegister = l:choice
	    if l:choice !=# '1'
		" Put any recalled history other that the last recall itself
		" back at the top.
		let l:recallIdentity = '"' . l:choice . "\n" . s:lastHistories[a:what]
	    endif
	elseif l:choice =~# '\a'
	    let s:lastHistories[a:what] = s:namedSources[a:what][l:choice]
	    let l:repeatRegister = l:choice
	    " Don't put the same name and identical contents at the top again if
	    " it's already there.
	    let l:recallIdentity = '"' . l:choice . "\n" . s:lastHistories[a:what]
	else
	    throw 'ASSERT: Unexpected l:choice: ' . l:choice
	endif
    elseif l:choice =~# '\d'
	if ! l:hasName
	    " Use the index for repeating the recall, unless this is being
	    " assigned a name; then, the count specifies the multiplier.
	    let l:repeatCount = str2nr(l:choice)
	endif
	let l:repeatRegister = a:register   " Use the named register this is being assigned to, or the default register.
	let s:lastHistories[a:what] = s:historySources[a:what][str2nr(l:choice) - 1]
	" Don't put the same count and identical contents at the top again if
	" it's already there.
	let l:recallIdentity = l:choice . "\n" . s:lastHistories[a:what]
    elseif l:choice =~# '\a'  | " Take {a-zA-Z} as a shortcut for "{a-zA-z}; unlike with the {1-9} recalls, there's no clash here.
	let l:repeatRegister = l:choice
	let s:lastHistories[a:what] = s:namedSources[a:what][l:choice]
	" Don't put the same name and identical contents at the top again if
	" it's already there.
	let l:recallIdentity = '"' . l:choice . "\n" . s:lastHistories[a:what]
    else
	throw 'ASSERT: Unexpected l:choice: ' . l:choice
    endif

    if l:hasName
	let s:namedSources[a:what][a:register] = s:lastHistories[a:what]
    endif

    call s:Recall(a:what, l:recallIdentity, l:repeatCount, l:repeatRegister, a:multiplier)
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
