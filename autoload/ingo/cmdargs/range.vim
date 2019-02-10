" ingo/cmdargs/range.vim: Functions for parsing Ex command ranges.
"
" DEPENDENCIES:
"   - ingo/cmdargs/commandcommands.vim autoload script
"
" Copyright: (C) 2012-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

let s:singleRangeExpr = '\%(\d*\|[.$*%]\|''\S\|\\[/?&]\|/.\{-}/\|?.\{-}?\)\%([+-]\d*\)\?'
let s:rangeExpr = s:singleRangeExpr . '\%([,;]' . s:singleRangeExpr . '\)\?'
function! ingo#cmdargs#range#SingleRangeExpr()
    return s:singleRangeExpr
endfunction
function! ingo#cmdargs#range#RangeExpr()
    return s:rangeExpr
endfunction

function! ingo#cmdargs#range#Parse( commandLine, ... )
"******************************************************************************
"* PURPOSE:
"   Parse a:commandLine into the range and the remainder. When the command line
"   contains multiple commands, the last one is parsed.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:commandLine   Ex command line containing a command.
"   a:options.isAllowEmptyCommand   Flag whether a sole range should be matched.
"				    True by default.
"   a:options.commandExpr           Custom pattern for matching commands /
"				    anything that follows the range. Mutually
"				    exclusive with
"				    a:options.isAllowEmptyCommand.
"   a:options.isParseFirstRange     Flag whether the first range should be
"				    parsed. False by default.
"   a:options.isOnlySingleAddress   Flag whether only a single address should be
"                                   allowed, and double line addresses are not
"                                   recognized as valid. False by default.
"* RETURN VALUES:
"   List of [fullCommandUnderCursor, combiner, commandCommands, range, remainder]
"	fullCommandUnderCursor  The entire command, potentially starting with
"				"|" when there's a command chain.
"	combiner    Empty, white space, or something with "|" that joins the
"		    command to the previous one.
"	commandCommands Empty or any prepended commands take another Ex command
"			as an argument.
"	range       The single or double line address(es), e.g. "42,'b".
"	remainder   The command; possibly empty (when a:isAllowEmptyCommand is
"		    true).
"   Or: [] if no match.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isAllowEmptyCommand = get(l:options, 'isAllowEmptyCommand', 1)
    let l:isParseFirstRange = get(l:options, 'isParseFirstRange', 0)
    let l:rangeExpr = (get(l:options, 'isOnlySingleAddress', 0) ?
    \   ingo#cmdargs#range#SingleRangeExpr() :
    \   ingo#cmdargs#range#RangeExpr()
    \)
    let l:commandExpr = get(l:options, 'commandExpr', (l:isAllowEmptyCommand ? '\(\h\w*.*\|$\)' : '\(\h\w*.*\)'))

    let l:parseExpr =
    \	(l:isParseFirstRange ? '\C^\(\s*\)' : '\C^\(.*\\\@<!|\)\?\s*') .
    \	'\(' . ingo#cmdargs#commandcommands#GetExpr() . '\)\?' .
    \	'\(' . l:rangeExpr . '\)\s*' .
    \   l:commandExpr
    return matchlist(a:commandLine, l:parseExpr)[0:4]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
