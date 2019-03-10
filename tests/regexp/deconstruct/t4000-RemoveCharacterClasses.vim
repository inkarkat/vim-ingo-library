" Test removing character classes and similar.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('foobar'), 'foobar', 'no character classes')

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('f\k\kbar'), 'fbar', 'a character class')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo[abcopq]!'), 'fo!', 'simple collection')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo[[:alnum:]xyz][^a-z]!'), 'fo!', 'multiple collections')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo\_[abcopq]!'), 'fo!', 'collection including EOL')

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('foo\%[bar]quux'), 'fooquux', 'an optional sequence')

call vimtest#Quit()
