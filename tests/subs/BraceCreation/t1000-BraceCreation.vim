" Test brace creation.

call vimtest#StartTap()
call vimtap#Plan(18)

call vimtap#Is(subs#BraceCreation#FromSplitString('fo! foX foo'), 'fo{!,X,o}', 'same prefix, different suffixes')
call vimtap#Is(subs#BraceCreation#FromSplitString('fox fooy foobar'), 'fo{x,oy,obar}', 'same prefix, different length suffixes')
call vimtap#Is(subs#BraceCreation#FromSplitString('myfoo theirfoo ourfoo'), '{my,their,our}foo', 'different prefixes, same suffix')
call vimtap#Is(subs#BraceCreation#FromSplitString('myfo! theirfoX ourfoo'), '{my,their,our}fo{!,X,o}', 'different prefixes, different suffixes')

call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo2 foo3'), 'foo{1..3}', 'same prefix, number sequence')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo2'), 'foo{1,2}', 'same prefix, short number sequence')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo3 foo5'), 'foo{1..5..2}', 'same prefix, number sequence with offset')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo3 foo5 fooX'), 'foo{{1..5..2},X}', 'same prefix, number sequence with offset and suffix')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo3 foo5 fooX'), 'foo{{1..5..2},X}', 'same prefix, number sequence with offset and suffix')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo3 foo5 fooX fooY'), 'foo{{1..5..2},X,Y}', 'same prefix, number sequence with offset and suffixes')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo3 foo5 fooX fooY fooZ'), 'foo{{1..5..2},{X..Z}}', 'same prefix, number sequence with offset and char sequence')
call vimtap#Is(subs#BraceCreation#FromSplitString('foo1 foo3 foo5 fooX fooY fooZ foo10 foo20 foo30 foo40'), 'foo{{1..5..2},X,Y,Z,10,20,30,40}', 'same prefix, number sequence with offset and char sequence and another number sequence (only first detected)')
call vimtap#Is(subs#BraceCreation#FromSplitString('fooX fooY fooZ foo1 foo3 foo5'), 'foo{{X..Z},{1..5..2}}', 'same prefix, char sequence and number sequence (not detected)')

call vimtap#Is(subs#BraceCreation#FromSplitString('FooHasBoo FooIsBoo FooCanBoo'), 'Foo{Has,Is,Can}Boo', 'two commons in outside')
call vimtap#Is(subs#BraceCreation#FromSplitString('myFooHasBooHere theirFooIsBooNow ourFooCanBooMore'), '{my,their,our}Foo{Has,Is,Can}Boo{Here,Now,More}', 'two commons in the middle')

call vimtap#Is(subs#BraceCreation#FromSplitString('foo,bar, fooxy'), 'foo{\,bar\,,xy}', 'embedded commas')
call vimtap#Is(subs#BraceCreation#FromSplitString('foobar foo{O} fooxy'), 'foo{bar,\{O\},xy}', 'embedded braces in one word')
call vimtap#Is(subs#BraceCreation#FromSplitString('foobar foo} foo{ fooxy'), 'foo{bar,\},\{,xy}', 'embedded braces in two words')

call vimtest#Quit()
