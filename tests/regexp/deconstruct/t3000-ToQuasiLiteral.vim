" Test converting to somewhat literal text.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('foobar'), 'foobar', 'no regexp, already literal text')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('fo*bar\?$'), 'fobar', 'simple regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('^\<fo[ox]\%(bar\|hos\)\>'), 'fo[ox]\%(bar\|hos\)', 'medium-complexity regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('^\%10lfo\{1,10}\~bar\?\n.*\t\<l\([aeiou]\)ll\1\>$'), "fo~bar\n.\tl\\([aeiou]\\)ll\\1", 'complex regexp')

call vimtest#Quit()
