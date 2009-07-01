" EchoLine.vim: :echo a line from the buffer with the original syntax
" highlighting. 
"
" DESCRIPTION:
"   Display the given line from the current buffer in the command line (i.e. via
"   :echo), using that line's syntax highlighting (i.e. as it is highlighted in
"   the buffer itself). 
"   If the line is longer than the available width in the command line, the
"   output is truncated so that no hit-enter prompt appears. 
"
" USAGE:
" INSTALLATION:
" DEPENDENCIES:
"   - EchoWithoutScrolling.vim autoload script
"
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"   - <Tab> are currently always rendered as ......; maybe use the settings from
"     'listchars'. 
"
" Copyright: (C) 2008-2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" Source: Based on ShowLine.vim (vimscript #381) by Gary Holloway
"
" REVISION	DATE		REMARKS 
"	003	15-May-2009	Cleanup. 
"				BF: Now translating <CR> and <LF> characters
"				into printable characters instead of letting
"				:echo break the line. 
"				BF: Using the correct 'SpecialKey' highlighting
"				for unprintable characters like Vim does. This
"				highlighting is not reported by synID(), and
"				thus must be taken care of separately. As a nice
"				side effect, the rendering of <Tab> characters
"				uses this highlighting, too. 
"	002	04-Aug-2008	Added s:GetCharacter(). 
"				Finished implementation. 
"	001	23-Jul-2008	file creation

function! s:GetVirtStartColOfCurrentCharacter( lineNum, column )
    let l:currentVirtCol = s:GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column - l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset]) + 1
endfunction
function! s:GetVirtColOfCurrentCharacter( lineNum, column )
    " virtcol() only returns the (end) virtual column of the current character
    " if the column points to the first byte of a multi-byte character. If we're
    " pointing to the middle or end of a multi-byte character, the end virtual
    " column of the _next_ character is returned. 
    let l:offset = 0
    while virtcol([a:lineNum, a:column - l:offset]) == virtcol([a:lineNum, a:column + 1])
	" If the next column's virtual column is the same, we're in the middle
	" of a multi-byte character, and must backtrack to get this character's
	" virtual column. 
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset])
endfunction
function! s:GetVirtColOfNextCharacter( lineNum, column )
    let l:currentVirtCol = s:GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column + l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column + l:offset])
endfunction

function! s:GetCharacter( line, column )
"*******************************************************************************
"* PURPOSE:
"   Retrieve a (full, in case of multi-byte) character from a:line, a:column. 
"   strpart(getline(a:line), a:column, 1) can only deal with single-byte chars. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"
"* RETURN VALUES: 
"   Character, or empty string if the position is invalid. 
"*******************************************************************************
    return matchstr( a:line, '\%' . a:column . 'c.' )
endfunction

function! s:GetTabReplacement( column, tabstop )
    return a:tabstop - (a:column - 1) % a:tabstop
endfunction 

function! s:IsMoreToRead( column )
    if a:column > s:endCol 
	return 0
    endif
    if s:maxLength <= 0
	return 1
    endif

    " The end column has not been reached yet, but a maximum length has been
    " set. We need to determine whether the next character would still fit. 
    let l:isMore =  (s:GetVirtColOfCurrentCharacter(s:lineNum, a:column) - s:virtStartCol + 1 <= s:maxLength)

"****D echomsg 'at column' a:column strpart(getline(s:lineNum), a:column - 1, 1) 'will have length' (s:GetVirtColOfCurrentCharacter(s:lineNum, a:column) - s:virtStartCol + 1) (l:isMore ? 'do it' : 'stop')

    return l:isMore
endfunction
function! s:IsInside( startCol, endCol, column )
    return a:column >= a:startCol && a:column <= a:endCol
endfunction
function! s:GetAdditionalHighlightGroup( column )
    for h in s:additionalHighlighting
	if s:IsInside( h[0], h[1], a:column )
	    return h[2]
	endif
    endfor
endfunction
function! s:GetHighlighting( line, column )
    let l:group = s:GetAdditionalHighlightGroup( a:column )
    if empty(l:group)
	let l:group = synIDattr(synID(a:line, a:column, 1), 'name')
    endif
    return l:group
endfunction
function! EchoLine#EchoLinePart( lineNum, startCol, endCol, maxLength, additionalHighlighting )
"*******************************************************************************
"* PURPOSE:
"   Display the current buffer's a:lineNum in the command line, using that
"   line's syntax highlighting. Additional highlighting groups can be applied on
"   top. 
"* ASSUMPTIONS / PRECONDITIONS:
"   l:lineNum refers to existing line in current buffer. 
"* EFFECTS / POSTCONDITIONS:
"   :echo's to the command line. 
"* INPUTS:
"   a:lineNum	Line number in current buffer to be displayed. 
"   a:startCol	Column number from where to start displaying (0: column 1). 
"   a:endCol	Last column number to be displayed (0: line's last column). 
"   a:maxLength	Maximum number of characters to be displayed; this can be
"		different from (a:endCol - a:startCol) if the line contains
"		<Tab> characters, and is useful to avoid the "Hit ENTER" prompt.
"		(0: unlimited length)
"   a:additionalHighlighting	
"		List of additional highlightings that should be layered on top
"		of the line's highlighting. Each list element consists of
"		[ startCol, endCol, highlightGroup ]. In case there is overlap
"		in the ranges, the first element that specifies a highlight
"		group for a column wins. 
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:cmd = ''
    let l:prev_group = ' '    " Something that won't match any syntax group name.
    let l:line = getline(a:lineNum)

    let l:column = (a:startCol == 0 ? 1 : a:startCol)

    let s:virtStartCol = s:GetVirtStartColOfCurrentCharacter(a:lineNum, l:column)
    let s:endCol = (a:endCol == 0 ? strlen(l:line) : a:endCol)
    let s:lineNum = a:lineNum
    let s:maxLength = a:maxLength
    let s:additionalHighlighting = a:additionalHighlighting

    if l:column == s:endCol
	let l:cmd .= 'echon "'
    endif

"****D echomsg 'start at virtstartcol' s:virtStartCol
    while s:IsMoreToRead( l:column )
	let l:char = s:GetCharacter(l:line, l:column)
	let l:group = s:GetHighlighting(a:lineNum, l:column)

	if l:char =~ '\%(\p\@![\x00-\xFF]\)'
	    " Emulate the built-in highlighting of translated unprintable
	    " characters here. The regexp also matches <CR> and <LF>, but no
	    " non-ASCII multi-byte characters; the 'isprint' option is not
	    " applicable to them. 
	    let l:group = 'SpecialKey'
	endif

	if l:group != l:prev_group
	    let l:cmd .= (empty(l:cmd) ? '' : '"|')
	    let l:cmd .= 'echohl ' . (empty(l:group) ? 'None' : l:group) . '|echon "'
"****D echomsg '****' printf('%4s', '"'. strtrans(l:char) . '"') l:group
	    let l:prev_group = l:group
	endif

	" <Tab> characters are rendered so that: 
	" 1. The tab width is the same as in the buffer (even when the echoed
	" position is shifted due to scrolling or a echo prefix). 
	" 2. It can be differentiated from a sequence of spaces. 
	"
	" The :echo command observes embedded line breaks (in contrast to
	" :echomsg), which would mess up a single-line message that contains
	" embedded \n = <CR> = ^M or <LF> = ^@.
	if l:char == "\t"
	    let l:width = s:GetTabReplacement(s:GetVirtStartColOfCurrentCharacter(a:lineNum, l:column), &l:tabstop)
	    let l:cmd .= repeat('.', l:width)
	elseif l:char == "\<CR>"
	    let l:cmd .= '^M'
	elseif l:char == "\<LF>"
	    let l:cmd .= '^@'
	else
	    let l:cmd .= escape(l:char, '"\')
	endif
	let l:column += strlen(l:char)
    endwhile
"****D echomsg '**** from' s:virtStartCol 'last col added' l:column - 1 | echomsg ''

    if a:maxLength > 0 && s:GetCharacter(l:line, l:column) == "\t"
	" The line has been truncated before a <Tab> character, so the maximum
	" length has not been used up. As there may be a highlighting prolonged
	" by the <Tab>, we still want to fill up the maximum length. 
	let l:width = s:virtStartCol + a:maxLength - s:GetVirtStartColOfCurrentCharacter(a:lineNum, l:column)
	if empty(l:cmd)
	    let l:cmd .= 'echon "'
	endif
	let l:cmd .= repeat('.', l:width) 
    endif

    let l:cmd .= '"|echohl None'
    "DEBUG call input('CMD='.l:cmd)
    exe l:cmd
endfunction

function! EchoLine#EchoLine( lineNum, centerCol, prefix, additionalHighlighting )
"*******************************************************************************
"* PURPOSE:
"   Display (part of) the current buffer's a:lineNum in the command line without
"   causing the "Hit ENTER" prompt, using that line's syntax highlighting.
"   Additional highlighting groups can be applied on top. The a:prefix text is
"   displayed before the line. When the line is too long to be displayed
"   completely, the a:centerCol column is centered, and parts of the line before
"   and after that are truncated. 
"* ASSUMPTIONS / PRECONDITIONS:
"   l:lineNum refers to existing line in current buffer. 
"* EFFECTS / POSTCONDITIONS:
"   :echo's to the command line, avoiding the "Hit ENTER" prompt. 
"* INPUTS:
"   a:lineNum	Line number in current buffer to be displayed. 
"   a:centerCol	Column number of the line that will be centered if the line is
"		too long to be displayed completely. Use 0 for truncation only
"		at the right side. 
"   a:prefix	String that will be echoed before the line. 
"   a:additionalHighlighting	
"		List of additional highlightings that should be layered on top
"		of the line's highlighting. Each list element consists of
"		[ startCol, endCol, highlightGroup ]. In case there is overlap
"		in the ranges, the first element that specifies a highlight
"		group for a column wins. 
"* RETURN VALUES: 
"   none
"*******************************************************************************

    let l:maxLength = EchoWithoutScrolling#MaxLength() - EchoWithoutScrolling#DetermineVirtColNum(a:prefix)
    let l:line = getline(line('.'))

    " The a:centerCol is specified in buffer columns, but the l:maxLength is in
    " screen space. To (more or less) bridge this mismatch, a constant factor of
    " 0 < (# of chars / bytes) <= 100 is assumed. 
    let l:numOfChars = strlen(substitute(EchoWithoutScrolling#RenderTabs(l:line, &tabstop, 1), '.', 'x', 'g'))
    let l:lengthToColFactor = 100 * l:numOfChars / strlen(l:line)
"****D echomsg '****' l:lengthToColFactor

    " Attention: columns start with 1, byteidx() starts with 0!
    let l:startCol = byteidx( l:line, max([1, (a:centerCol * l:lengthToColFactor / 100) - (l:maxLength / 2)]) - 1 ) + 1

    echon a:prefix
    call EchoLine#EchoLinePart( a:lineNum, l:startCol, 0, l:maxLength, a:additionalHighlighting )
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
