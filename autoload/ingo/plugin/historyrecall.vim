" ingo/plugin/historyrecall.vim: Functions for providing recall from a history of values.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:historySources = {}
let s:namedSources = {}
let s:recallsSources = {}
let s:Callbacks = {}
let s:recalledIdentities = {}
let s:lastHistories = {}
let s:whatPlurals = {}
let s:options = {}

function! ingo#plugin#historyrecall#Register( what, historySource, namedSource, recallsSource, Callback, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Register a history type of a:what with source data and the a:Callback to
"   invoke on recall.
"* USAGE:
"   call ingo#plugin#historyrecall#Register('what',
"   \   function('What#GetHistory'), {}, [],
"   \   function('What#Recall')
"   \)
"
"   function! What#GetHistory() abort
"       return ['foo', 'bar', 'baz']
"   endfunction
"   function! What#Recall( what, repeatCount, register, multiplier  ) abort
"       echomsg printf('I got %s %d times.', a:what, a:multiplier)
"	silent! call repeat#set("\<Plug>(HistoryRecallWhatRepeat)", a:repeatCount)
"	silent! call repeat#setreg("\<Plug>(HistoryRecallWhatRepeat)", a:register)
"	return 1
"   endfunction
"
"   nnoremap <silent> <Plug>(HistoryRecallWhat)
"   \ :<C-u>if ! ingo#plugin#historyrecall#Recall('what', v:count1, v:count, v:register)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
"   if ! hasmapto('<Plug>(HistoryRecallWhat)', 'n')
"       nmap qX <Plug>(HistoryRecallWhat)
"   endif
"   nnoremap <silent> <Plug>(HistoryRecallListWhat)
"   \ :<C-u>if ! ingo#plugin#historyrecall#List('what', v:count1, v:register)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
"   if ! hasmapto('<Plug>(HistoryRecallListWhat)', 'n')
"       nmap qx <Plug>(HistoryRecallListWhat)
"   endif
"   nnoremap <silent> <Plug>(HistoryRecallWhatRepeat)
"   \ :<C-u>if ! ingo#plugin#historyrecall#RecallRepeat('what', v:count1, v:count, v:register)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Name of the type of history; this will be used in messages like "No
"           recalled {what} yet." If the plural form is irregular, can also be a
"           List of [{what}, {whatPlural}}.
"   a:historySource List of history items, from newest to oldest. The first 9
"                   will be offered to the user in the interactive list, all can
"                   be recalled via a [count]. Can be a List or Funcref that is
"                   invoked without arguments and returns a List. If the former,
"                   ensure to keep the original List; i.e. only add() (/
"                   extend()) / remove(), but do not assign a new List after
"                   registration!
"   a:namedSource   Dictionary of letter to history items. If you don't need
"                   access to these yourself (e.g. for persistence), just pass
"                   {}. Else, the same options as for a:historySource apply.
"   a:recallsSource List of history items. If you don't need access to these
"                   yourself (e.g. for persistence), just pass []. Else, the
"                   same options as for a:historySource apply.
"   a:Callback      Funcref that gets invoked if the user recalled this with the
"                   chosen history item, repeatCount (to be forwarded to
"                   repeat#set()), register (to be forwarded to
"                   repeat#setreg()), multiplier (from a passed [count]). The
"                   return value (signifying success or failure) is passed back
"                   to the client.
"   a:options.isUniqueRecalls
"                   Flag whether a recall will remove identical recalls from
"                   a:recallsSource; by default true.
"* RETURN VALUES:
"   None.
"******************************************************************************
    let [l:what, l:whatPlural] = (type(a:what) == type([]) ? a:what : [a:what, a:what . 's'])
    let s:historySources[l:what] = a:historySource
    let s:namedSources[l:what] = a:namedSource
    let s:recallsSources[l:what] = a:recallsSource
    let s:Callbacks[l:what] = a:Callback
    let s:recalledIdentities[l:what] = ''
    let s:lastHistories[l:what] = ''
    let s:whatPlurals[l:what] = l:whatPlural
    let s:options[l:what] = (a:0 ? a:1 : {})
endfunction

function! s:GetSource( source, what ) abort
    return (type(a:source[a:what]) == type(function('tr')) ?
    \   call(a:source[a:what], []) :
    \   a:source[a:what]
    \)
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
	let l:history = s:GetSource(s:historySources, a:what)
	if len(l:history) == 0
	    call ingo#err#Set(printf('No %s yet', s:whatPlurals[a:what]))
	    return 0
	elseif len(l:history) < a:count
	    call ingo#err#Set(printf('There %s only %d %s in the history',
	    \   len(l:history) == 1 ? 'is' : 'are',
	    \   len(l:history),
	    \   len(l:history) == 1 ? a:what : s:whatPlurals[a:what]
	    \))
	    return 0
	endif

	let l:multiplier = 1
	let s:lastHistories[a:what] = l:history[a:count - 1]
	let l:recallIdentity = a:count . "\n" . s:lastHistories[a:what]
    elseif a:register =~# '[1-9]'
	let l:recalls = s:GetSource(s:recallsSources, a:what)
	let l:index = str2nr(a:register) - 1
	if len(l:recalls) == 0
	    call ingo#err#Set(printf('No recalled %s yet', s:whatPlurals[a:what]))
	    return 0
	elseif len(l:recalls) <= l:index
	    call ingo#err#Set(printf('There %s only %d recalled %s',
	    \   len(l:recalls) == 1 ? 'is' : 'are',
	    \   len(l:recalls),
	    \   len(l:recalls) == 1 ? a:what : s:whatPlurals[a:what]
	    \))
	    return 0
	endif

	let l:multiplier = a:count
	let s:lastHistories[a:what] = l:recalls[l:index]
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

    return s:Recall(a:what, l:recallIdentity, a:repeatCount, a:register, l:multiplier)
endfunction
function! s:Recall( what, recallIdentity, repeatCount, register, multiplier )
    if ! empty(a:recallIdentity) && a:recallIdentity !=# s:recalledIdentities[a:what]
	" It's not a repeat of the last recalled thing; put it at the first
	" position of the recall stack.
	let l:recalls = s:GetSource(s:recallsSources, a:what)
	if get(s:options[a:what], 'isUniqueRecalls', 1)
	    call filter(l:recalls, 'v:val !=# s:lastHistories[a:what]')
	endif
	call insert(l:recalls, s:lastHistories[a:what])
	if len(l:recalls) > 9
	    call remove(l:recalls, 9, -1)
	endif
	if a:recallIdentity =~# '^"\d\n'
	    " The recalled thing has been moved to the top position again; adapt
	    " the position, so that a repeat with the same number will continue
	    " cycling (by putting the thing to the top even though it's
	    " identical); only a recall with the top position ("1) should leave
	    " it as-is.
	    let s:recalledIdentities[a:what] = '"1' . a:recallIdentity[2:]
	else
	    let s:recalledIdentities[a:what] = a:recallIdentity
	endif
    endif

    return call(s:Callbacks[a:what], [s:lastHistories[a:what], a:repeatCount, a:register, a:multiplier])
endfunction
function! ingo#plugin#historyrecall#List( what, multiplier, register )
    let l:validNames = filter(
    \   split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs'),
    \   'has_key(s:namedSources[a:what], v:val)'
    \)
    let l:history = s:GetSource(s:historySources, a:what)
    let l:recalls = s:GetSource(s:recallsSources, a:what)
    let l:recallNum = len(l:recalls)

    if len(l:history) + len(l:validNames) + l:recallNum == 0
	call ingo#err#Set(printf('No %s yet', s:whatPlurals[a:what]))
	return 0
    endif

    let l:hasName = s:HasName(a:register)
    echohl Title
    echo ' #  ' . a:what
    echohl None
    for l:i in range(1, l:recallNum)
	echo '"' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(l:recalls[l:i - 1])
    endfor
    for l:i in l:validNames
	echo '"' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(s:namedSources[a:what][l:i])
    endfor
    for l:i in range(min([9, len(l:history)]), 1, -1)
	echo ' ' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(l:history[l:i - 1])
    endfor

    let l:validNamesAndRecalls = join(l:validNames, '') . join(range(1, l:recallNum), '')
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
	    let s:lastHistories[a:what] = l:recalls[str2nr(l:choice) - 1]
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
	let s:lastHistories[a:what] = l:history[str2nr(l:choice) - 1]
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
	let l:recallIdentity = '"' . a:register . "\n" . s:lastHistories[a:what]
    endif

    return s:Recall(a:what, l:recallIdentity, l:repeatCount, l:repeatRegister, a:multiplier)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
