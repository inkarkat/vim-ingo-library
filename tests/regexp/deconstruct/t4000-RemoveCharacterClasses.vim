" Test removing character classes and similar.

call vimtest#StartTap()
call vimtap#Plan(11)

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('foobar'), 'foobar', 'no character classes')

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('f\k\kbar'), 'fbar', 'a character class')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo[abcopq]!'), 'fo!', 'simple collection')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo[[:alnum:]xyz][^a-z]!'), 'fo!', 'multiple collections')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo\_[abcopq]!'), 'fo!', 'collection including EOL')

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('foo\%[bar]quux'), 'fooquux', 'an optional sequence')

call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo\%d120bar'), 'foxbar', 'decimal escape')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo\%o170bar'), 'foxbar', 'octal escape')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('fo\%x78bar\%x2e'), 'foxbar.', 'hex escapes')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('\%u20ac\%u269B'), "\u20ac\u269b", 'unicode BMP escapes')
call vimtap#Is(ingo#regexp#deconstruct#RemoveCharacterClasses('\%U1F4A5'), "\U1f4a5", 'unicode non-BMP escape')

call vimtest#Quit()
