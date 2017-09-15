" Test brace expansion.

call vimtest#StartTap()
call vimtap#Plan(15)

call vimtap#Is(subs#BraceExpansion#Do('fo{!,X,o}'), 'fo! foX foo', 'same prefix, different suffixes')
call vimtap#Is(subs#BraceExpansion#Do('fo{x,oy,obar}'), 'fox fooy foobar', 'same prefix, different length suffixes')
call vimtap#Is(subs#BraceExpansion#Do('{my,their,our}foo'), 'myfoo theirfoo ourfoo', 'different prefixes, same suffix')
call vimtap#Is(subs#BraceExpansion#Do('{my,their,our}fo{!,X,o}'), 'myfo! theirfoX ourfoo', 'different prefixes, different suffixes')

call vimtap#Is(subs#BraceExpansion#Do('foo{1..3}'), 'foo1 foo2 foo3', 'same prefix, number sequence')
call vimtap#Is(subs#BraceExpansion#Do('foo{1,2}'), 'foo1 foo2', 'same prefix, short number sequence')
call vimtap#Is(subs#BraceExpansion#Do('foo{1..5..2}'), 'foo1 foo3 foo5', 'same prefix, number sequence with offset')
call vimtap#Is(subs#BraceExpansion#Do('foo{{1..5..2},X}'), 'foo1 foo3 foo5 fooX', 'same prefix, number sequence with offset and suffix')
call vimtap#Is(subs#BraceExpansion#Do('foo{{1..5..2},X}'), 'foo1 foo3 foo5 fooX', 'same prefix, number sequence with offset and suffix')
call vimtap#Is(subs#BraceExpansion#Do('foo{{1..5..2},X,Y}'), 'foo1 foo3 foo5 fooX fooY', 'same prefix, number sequence with offset and suffixes')
call vimtap#Is(subs#BraceExpansion#Do('foo{{1..5..2},{X..Z}}'), 'foo1 foo3 foo5 fooX fooY fooZ', 'same prefix, number sequence with offset and char sequence')
call vimtap#Is(subs#BraceExpansion#Do('foo{{1..5..2},X,Y,Z,10,20,30,40}'), 'foo1 foo3 foo5 fooX fooY fooZ foo10 foo20 foo30 foo40', 'same prefix, number sequence with offset and char sequence and another number sequence (only first detected)')
call vimtap#Is(subs#BraceExpansion#Do('foo{{X..Z},{1..5..2}}'), 'fooX fooY fooZ foo1 foo3 foo5', 'same prefix, char sequence and number sequence (not detected)')

call vimtap#Is(subs#BraceExpansion#Do('Foo{Has,Is,Can}Boo'), 'FooHasBoo FooIsBoo FooCanBoo', 'two commons in outside')
call vimtap#Is(subs#BraceExpansion#Do('{my,their,our}Foo{Has,Is,Can}Boo{Here,Now,More}'), 'myFooHasBooHere theirFooIsBooNow ourFooCanBooMore', 'two commons in the middle')

call vimtest#Quit()
