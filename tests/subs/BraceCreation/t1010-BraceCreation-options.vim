" Test brace creation with options.

call vimtest#StartTap()
call vimtap#Plan(9)

function! s:Call( text, options )
    return ingo#subs#BraceCreation#FromSplitString(a:text, '', a:options)
endfunction

call vimtap#Is(s:Call('abc def zyz', {}), '{abc,def,zyz}', 'no common substrings')
call vimtap#Is(s:Call('abc def zyz', {'returnValueOnFailure' : ''}), '', 'no common substrings')

call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {}), 'Foo{Has,,}Bo{o,o,x}', 'optional inner default')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'optionalElementInSquareBraces': 1}), 'Foo[Has]Bo{o,o,x}', 'optional inner in square braces')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'uniqueElements': 1}), 'Foo{Has,}Bo{o,x}', 'unique')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'uniqueElements': 1, 'optionalElementInSquareBraces': 1}), 'Foo[Has]Bo{o,x}', 'unique and square braces')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'short': 1}), 'Foo[Has]Bo{o,x}', 'short = unique and square braces')

call vimtap#Is(s:Call('fooHasBoo FOOBoo FooBox', {'optionalElementInSquareBraces': 1, 'isIgnoreCase': 1}), 'foo[Has]Bo{o,o,x}', 'case-insensitive optional inner in square braces')
call vimtap#Is(s:Call('addField field', {'optionalElementInSquareBraces': 1, 'isIgnoreCase': 1}), '[add]Field', 'case-insensitive optional end in square braces')

call vimtest#Quit()
