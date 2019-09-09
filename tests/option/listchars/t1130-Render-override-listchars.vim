" Test rendering with a passed listchars Dictionary.

set listchars=tab:>-,eol:$

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", 1, {'tab': '^I', 'eol': '^J'}), '^I^I  some text^I^J', 'text rendered at end')

call vimtest#Quit()
