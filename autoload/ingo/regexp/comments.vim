" ingo/regexp/comments.vim: Functions that converts 'comments' to regular expressions.
"
" DEPENDENCIES:
"   - ingo/option.vim autoload script
"   - IndentCommentPrefix.vim plugin (optional integration)
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#regexp#comments#CommentToExpression( comment )
    let [l:flags, l:comment] = matchlist(a:comment, '\([^:]*\):\(.*\)')[1:2]
    let l:commentExpr = ingo#regexp#EscapeLiteralText(l:comment)

    " Observe when a blank is required after the comment string, but do not
    " include it in the match, so that it is preserved during the join.
    " Illustration: With :setlocal comments=b:#,:>
    " # This is				>This is
    " # text.				> specta
    " Will be joined to			>cular.
    " # This is text.			Will be joined to
    "					>This is spectacular.
    return (l:flags =~# 'b' ? l:commentExpr . '\%(\s\|$\)\@=' : l:commentExpr)
endfunction
function! ingo#regexp#comments#FromSetting()
    if empty(&l:comments)
	" For this buffer, no comment markers are defined. Use any non-word
	" non-whitespace sequence as a generalization.
	let l:commentExpressions = ['\%(\W\&\S\)\+']
    else
	" Convert each comment marker of the 'comments' setting into a regular
	" expression.
	let l:commentExpressions = map(ingo#option#Split(&l:comments), 'ingo#regexp#comments#CommentToExpression(v:val)')
    endif

    " Integration with IndentCommentPrefix.vim plugin.
    let l:commentExpressions += map(copy(ingo#plugin#setting#GetBufferLocal('IndentCommentPrefix_Whitelist', [])), 'escape(v:val, ''\\'')')

    return l:commentExpressions
endfunction

function! ingo#regexp#comments#GetFlexibleWhitespaceAndCommentPrefixPattern( isAllowEmpty )
"******************************************************************************
"* PURPOSE:
"   Obtain a regular expression that matches any amount of whitespace (with
"   a:isAllowEmpty also none at all) and optionally any of the currently valid
"   comment prefixes in between.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isAllowEmpty  Flag whether to allow a zero-length match of nothing at all.
"* RETURN VALUES:
"   Regular expression.
"******************************************************************************
    let l:commentPattern = '\%(' . join(ingo#regexp#comments#FromSetting(), '\|') . '\)'
    return '\_s' . (a:isAllowEmpty ? '*' : '\+') . l:commentPattern . '\?\_s*'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
