" Test find all common substrings with a minimum length of the differing parts.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar','yourfoosball'], 1, 0),
\   [[['m', ''], ['', 'our'], ['', 's'], ['r', 'll']], ['y', 'foo', 'ba']],
\   'no minimumDifferingLength'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar','yourfoosball'], 1, 1),
\   [[['my', 'your'], ['bar', 'sball']], ['foo']],
\   'minimumDifferingLength filters empty'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobarx','yourfoosballx'], 1, 1),
\   [[['my', 'your'], ['bar', 'sball'], []], ['foo', 'x']],
\   'minimumDifferingLength filters empty, common at end'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['Ilovefoobar','Imissfoosball'], 1, 1),
\   [[[], ['love', 'miss'], ['bar', 'sball']], ['I', 'foo']],
\   'minimumDifferingLength filters empty, common at begin'
\)

call vimtest#Quit()
