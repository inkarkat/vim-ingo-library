" ingo/plugin/rendered.vim: Functions to interactively work with rendered items.
"
" DEPENDENCIES:
"   - ingo/avoidprompt.vim autoload script
"   - ingo/query.vim autoload script
"   - ingo/subs/BraceCreation.vim autoload script
"   - ingo/plugin/rendered/*.vim autoload scripts
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#plugin#rendered#List( what, renderer, additionalOptions, items )
"******************************************************************************
"* PURPOSE:
"   Allow interactive reordering, filtering, and eventual rendering of List
"   a:items (and potentially more a:additionalOptions).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Text describing what each element in a:items represents (e.g.
"           "matches").
"   a:renderer  Object that implements the rendering of the a:items.
"		Can supply additional rendering options presented to the user,
"		in a:renderer.options List. If such an option is chosen,
"		a:renderer.handleOption(command) is invoked. Finally,
"		a:renderer.render(items) is used to render the List.
"		This library ships with some default renderers that can be
"		copy()ed and passed; see below.
"   a:additionalOptions List of additional options presented to the user. Can
"                       include "&" accelerators; these will be dropped in the
"                       command passed to a:renderer.handleOption().
"   a:items     List of items to be renderer.
"* RETURN VALUES:
"   List of [command, renderedItems]. The command contains "Quit" if the user
"   chose to cancel. If an additional option was chosen, command contains the
"   option (without "&" accelerators), and renderedItems the (so far unrendered,
"   but potentially filtered) List of a:items. If an ordering was chosen,
"   command is empty and renderedItems contains the result.
"******************************************************************************
    let l:items = a:items
    let l:processOptions = a:additionalOptions + ['&Confirm each', '&Subset', '&Quit']
    let l:renderChoices = map(copy(a:renderer.options), 'ingo#query#StripAccellerator(v:val)')
    let l:additionalChoices = map(copy(a:additionalOptions), 'ingo#query#StripAccellerator(v:val)')

    let l:save_guioptions = &guioptions
    set guioptions+=c
    try
	while 1
	    redraw
	    let l:orderingOptions = []
	    let l:orderingToItems = {}
	    let l:orderingToString = {}
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, '&Original',   a:renderer, l:items, l:items)
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, 'Re&versed',   a:renderer, l:items, reverse(copy(l:items)))
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, '&Ascending',  a:renderer, l:items, sort(copy(l:items)))
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, '&Descending', a:renderer, l:items, reverse(sort(copy(l:items))))

	    let l:orderingMessage = printf('Choose ordering for %d %s: ', len(l:items), a:what)

	    let l:ordering = ingo#query#ConfirmAsText(l:orderingMessage, l:orderingOptions + a:renderer.options + l:processOptions, 1)
	    if empty(l:ordering) || l:ordering ==# 'Quit'
		return ['Quit', '']
	    elseif l:ordering ==# 'Confirm each' || l:ordering == 'Subset'
		if v:version < 702 | runtime autoload/ingo/plugin/rendered/*.vim | endif  " The Funcref doesn't trigger the autoload in older Vim versions.
		let l:ProcessingFuncref = function('ingo#plugin#rendered#' . substitute(l:ordering, '\s', '', 'g') . '#Filter')
		let l:items = call(l:ProcessingFuncref, [l:items])
	    elseif index(l:renderChoices, l:ordering) != -1
		call call(a:renderer.handleOption, [l:ordering])
	    elseif index(l:additionalChoices, l:ordering) != -1
		return [l:ordering, l:items]
	    else
		break
	    endif
	endwhile
    finally
	let &guioptions = l:save_guioptions
    endtry

    return ['', l:orderingToString[l:ordering]]
endfunction
function! s:AddOrdering( orderingOptions, orderingToItems, orderingToString, option, renderer, items, reorderedItems )
    if a:reorderedItems isnot# a:items && a:reorderedItems ==# a:items ||
    \   index(values(a:orderingToItems), a:reorderedItems) != -1
	return
    endif

    let l:option = substitute(a:option, '&', '', 'g')
    let l:string = call(a:renderer.render, [a:reorderedItems])

    if index(values(a:orderingToString), l:string) != -1
	" Different ordering yields same rendered string; skip.
	return
    endif

    call add(a:orderingOptions, a:option)
    let a:orderingToItems[l:option] = a:reorderedItems
    let a:orderingToString[l:option] = l:string

    call ingo#avoidprompt#EchoAsSingleLine(printf("%s:\t%s", l:option, l:string))
endfunction



"******************************************************************************
"* PURPOSE:
"   Renderer that joins the items on a self.separator, and optionally wraps the
"   result in self.prefix and self.suffix.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"******************************************************************************
let g:ingo#plugin#rendered#JoinRenderer = {
\   'options': [],
\   'prefix': '',
\   'separator': '',
\   'suffix': '',
\}
function! g:ingo#plugin#rendered#JoinRenderer.render( items ) dict
    return self.prefix . join(a:items, self.separator) . self.suffix
endfunction
function! g:ingo#plugin#rendered#JoinRenderer.handleOption( command ) dict
endfunction

"******************************************************************************
"* PURPOSE:
"   Renderer that extracts common substrings and turns these into a Brace
"   Expression, like in Bash. The algorithm's parameters can be tweaked by the
"   user. These tweaks override any defaults in self.braceOptions, which is the
"   configuration passed to ingo#subs#BraceCreation#FromList().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"******************************************************************************
let g:ingo#plugin#rendered#BraceExpressionRenderer = {
\   'options': ['Longer co&mmon', 'Shor&ter common', 'Longer disti&nct', 'Sho&rter distinct'],
\   'commonLengthOffset': 0,
\   'differingLengthOffset': 0,
\   'braceOptions': {}
\}
function! g:ingo#plugin#rendered#BraceExpressionRenderer.render( items ) dict
    let self.braceOptions.minimumCommonLength = max([1, get(self.options, 'minimumCommonLength', 1) + self.commonLengthOffset])
    let self.braceOptions.minimumDifferingLength = max([0, get(self.options, 'minimumDifferingLength', 0) + self.differingLengthOffset])

    return ingo#subs#BraceCreation#FromList(a:items, self.braceOptions)
endfunction
function! g:ingo#plugin#rendered#BraceExpressionRenderer.handleOption( command ) dict
    if a:command ==# 'Longer common'
	let self.commonLengthOffset += 1
    elseif a:command ==# 'Shorter common'
	let self.commonLengthOffset -= 1
    elseif a:command ==# 'Longer distinct'
	let self.differingLengthOffset += 1
    elseif a:command ==# 'Shorter distinct'
	let self.differingLengthOffset -= 1
    else
	throw 'ASSERT: Invalid render command: ' . string(a:command)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
