" Display the given line(s) from the current file in the command area (i.e.,
" echo), using that line's syntax highlighting (i.e., WYSIWYG).
"
" If no line number is given, display the current line.
"
" Regardless of how many line numbers are given, only the first &cmdheight
" lines are shown (i.e., don't cause scrolling, and a "more" message).
"
" $Header: /usr/home/gary/.vim/autoload/RCS/ShowLine.vim,v 1.1 2002/08/15 20:03:36 gary Exp $

function! EchoLine#EchoLinePart( lineNum, startCol, endCol, additionalHighlighting )
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
"   a:lineNum	line number in current buffer to be displayed
"   a:startCol	column number from where to start displaying (0: column 1)
"   a:endCol	last column number to be displayed (0: line's last column)
"   a:additionalHighlighting	
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:cmd = ''
    let l:prev_group = ' '    " Something that won't match any syntax group name.

    let l:column = (a:startCol == 0 ? 1 : a:startCol)
    let l:endCol = (a:endCol == 0 ? strlen(getline(a:lineNum)) : a:endCol)

    if l:column == l:endCol
	let l:cmd .= 'echon "'
    endif

    while l:column <= l:endCol
	let l:group = synIDattr(synID(a:lineNum, l:column, 1), 'name')
	if l:group != l:prev_group
	    let l:cmd .= (empty(l:cmd) ? '' : '"|')
	    let l:cmd .= 'echohl ' . (empty(l:group) ? 'NONE' : l:group) . '|echon "'
	    let l:prev_group = l:group
	endif
	let l:cmd .= escape( strpart(getline(a:lineNum), l:column - 1, 1), '"\' )
	let l:column += 1
    endwhile

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
