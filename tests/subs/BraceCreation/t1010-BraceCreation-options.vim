" Test brace creation with options.

call vimtest#StartTap()
call vimtap#Plan(0)

call vimtap#Is(subs#BraceCreation#FromSplitString('FooHasBoo FooBoo'), 'Foo{Has,}Boo', 'two commons in outside')
call vimtap#Is(subs#BraceCreation#FromSplitString('FooHasBoo FooBoo', '', {'optionalElementInSquareBraces': 1}), 'Foo[Has]Boo', 'two commons in outside')

call vimtest#Quit()
