" Display the given line(s) from the current file in the command area (i.e.,
" echo), using that line's syntax highlighting (i.e., WYSIWYG).
"
" If no line number is given, display the current line.
"
" Regardless of how many line numbers are given, only the first &cmdheight
" lines are shown (i.e., don't cause scrolling, and a "more" message).
"
" $Header: /usr/home/gary/.vim/autoload/RCS/ShowLine.vim,v 1.1 2002/08/15 20:03:36 gary Exp $

function! VirtStartCol( lineNum, column )
    " As virtcol() returns the end position of a <Tab>, we need to decrement the
    " start column, then increment the result, because we're interested in the
    " start column. 
    "return virtcol([a:lineNum, a:column - 1]) + 1
    return GetVirtStartColOfCurrentCharacter(a:lineNum, a:column)
endfunction

function! GetVirtStartColOfCurrentCharacter( lineNum, column )
    let l:currentVirtCol = GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column - l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column - l:offset]) + 1
endfunction
function! GetVirtColOfCurrentCharacter( lineNum, column )
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
function! GetVirtColOfNextCharacter( lineNum, column )
    let l:currentVirtCol = GetVirtColOfCurrentCharacter(a:lineNum, a:column)
    let l:offset = 1
    while virtcol([a:lineNum, a:column + l:offset]) == l:currentVirtCol
	let l:offset += 1
    endwhile
    return virtcol([a:lineNum, a:column + l:offset])
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
    let l:isMore =  (GetVirtColOfCurrentCharacter(s:lineNum, a:column) - s:virtStartCol + 1 <= s:maxLength)

echomsg 'at column' a:column strpart(getline(s:lineNum), a:column - 1, 1) 'will have length' (GetVirtColOfCurrentCharacter(s:lineNum, a:column) - s:virtStartCol + 1) (l:isMore ? 'do it' : 'stop')

    return l:isMore
endfunction

function! GetCharacter( line, column )
    return matchstr( a:line, '\%' . a:column . 'c.' )
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
"   a:lineNum	Line number in current buffer to be displayed
"   a:startCol	Column number from where to start displaying (0: column 1)
"   a:endCol	Last column number to be displayed (0: line's last column)
"   a:maxLength	Maximum number of characters to be displayed; this can be
"		different from (a:endCol - a:startCol) if the line contains
"		<Tab> characters, and is useful to avoid the "Hit ENTER" prompt.
"		(0: unlimited length)
"   a:additionalHighlighting	
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:cmd = ''
    let l:prev_group = ' '    " Something that won't match any syntax group name.
    let l:line = getline(a:lineNum)

    let l:column = (a:startCol == 0 ? 1 : a:startCol)

    let s:virtStartCol = VirtStartCol(a:lineNum, l:column)
    let s:endCol = (a:endCol == 0 ? strlen(l:line) : a:endCol)
    let s:lineNum = a:lineNum
    let s:maxLength = a:maxLength

    if l:column == s:endCol
	let l:cmd .= 'echon "'
    endif

echomsg 'start at virtstartcol' s:virtStartCol
    while s:IsMoreToRead( l:column )
	let l:group = synIDattr(synID(a:lineNum, l:column, 1), 'name')
	if l:group != l:prev_group
	    let l:cmd .= (empty(l:cmd) ? '' : '"|')
	    let l:cmd .= 'echohl ' . (empty(l:group) ? 'NONE' : l:group) . '|echon "'
	    let l:prev_group = l:group
	endif
	let l:char = GetCharacter(l:line, l:column)
	if l:char == "\t"
	    let l:width = EchoWithoutScrolling#GetTabReplacement(VirtStartCol(a:lineNum, l:column), &l:tabstop)
	    let l:cmd .= repeat('.', l:width)
	else
	    let l:cmd .= escape(l:char, '"\')
	endif
	let l:column += strlen(l:char)
    endwhile
    echomsg '**** from' s:virtStartCol 'last col added' l:column - 1 | echomsg ''

    if a:maxLength > 0 && GetCharacter(l:line, l:column) == "\t"
	" The line has been truncated before a <Tab> character, so the maximum
	" length has not been used up. As there may be a highlighting prolonged
	" by the <Tab>, we still want to fill up the maximum length. 
	let l:width = s:virtStartCol + a:maxLength - VirtStartCol(a:lineNum, l:column)
	let l:cmd .= repeat('.', l:width) 
    endif

    let l:cmd .= '"|echohl NONE'
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
"   a:lineNum	line number in current buffer to be displayed
"   a:centerCol	column number of the line that will be centered if the line is
"		too long to be displayed completely. Use 0 for truncation only
"		at the right side. 
"* RETURN VALUES: 
"   none
"*******************************************************************************
endfunction

function! ShowLine(...)
    " This makes sure we start (subsequent) echo's on the first line in the
    " command-line area.
    "
    echo ''

    let cmd	  = ''
    let prev_group = ' x '    " Something that won't match any syntax group name.

    if a:0 == 0
	call ShowLine(line("."))
	return
    endif

    let argn = 1
    let show = 0
    while argn <= a:0 "{
	if a:{argn} > 0
	    let show = show + 1
	endif
	let argn = argn + 1
    endwhile "}
    if &cmdheight < show && show <= 5
	let &cmdheight = show
    endif

    let argn  = 1
    let shown = 0
    while argn <= a:0 "{
	if a:{argn} > 0 "{
	    if shown > 0
		let cmd = cmd . '\n'
	    endif

	    let shown  = shown + 1
	    let length = strlen(getline(a:{argn}))
	    let column = 1

	    if length == 0
		let cmd = cmd . 'echon "'
	    endif

	    while column <= length "{
		let group = synIDattr(synID(a:{argn}, column, 1), 'name')
		if group != prev_group
		    if cmd != ''
			let cmd = cmd . '"|'
		    endif
		    let cmd = cmd . 'echohl ' . (group == '' ? 'NONE' : group) . '|echon "'
		    let prev_group = group
		endif
		let char = strpart(getline(a:{argn}), column - 1, 1)
		if char == '"' || char == "\\"
		    let char = '\' . char
		endif
		let cmd = cmd . char
		let column = column + 1
	    endwhile "}

	    if shown == &cmdheight
		break
	    endif
	endif "}

	let argn = argn + 1
    endwhile "}

    let cmd = cmd . '"|echohl NONE'
    "DEBUG call input('CMD='.cmd)
    exe cmd
endfunction
