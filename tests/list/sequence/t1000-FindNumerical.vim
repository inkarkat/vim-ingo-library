" Test find numerical sequences.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(ingo#list#sequence#FindNumerical([]), [0, 0], 'empty list')
call vimtap#Is(ingo#list#sequence#FindNumerical([1]), [0, 0], 'single element list')

call vimtap#Is(ingo#list#sequence#FindNumerical([1, 2]), [2, 1], '1, 2 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([2, 8]), [2, 6], '2, 8 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([1, 2, 3]), [3, 1], '1, 2, 3 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([2, 4, 6, 8]), [4, 2], '2, 4, 6, 8 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([-2, -8]), [2, -6], '-2, -8 list')

call vimtap#Is(ingo#list#sequence#FindNumerical([1, 2, 4]), [2, 1], '1, 2 list with additional 4')
call vimtap#Is(ingo#list#sequence#FindNumerical([2, 4, 6, 8, 5, 10]), [4, 2], '2, 4, 6, 8 list with additional 5, 10')

call vimtest#Quit()
