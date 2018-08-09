" Test substitution of indexed matches.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', 'g'), 'fXXbar is lXXsie XrigXn', 'global substitution')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [3]), 'foobar is loXsie origon', 'substitute single index')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [0, 2, 4]), 'fXobar is lXosie Xrigon', 'substitute even indices')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [1, 3, 5]), 'foXbar is loXsie origXn', 'substitute odd indices')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [2, 3, 4]), 'foobar is lXXsie Xrigon', 'substitute subsequent indices')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [99]), 'foobar is loosie origon', 'index out of range yields no substitution')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [-1]), 'foobar is loosie origon', 'negative index yields no substitution')

call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [2, 3, 4], 0), 'foobar is lXXsie Xrigon', 'substitute without inversion')
call vimtap#Is(ingo#subst#Indexed('foobar is loosie origon', 'o', 'X', [2, 3, 4], 1), 'fXXbar is loosie origXn', 'substitute with inversion')

call vimtest#Quit()
