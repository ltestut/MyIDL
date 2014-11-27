PRO print_sort_julval,st,N=N
; print the sorted val and jul values

IF NOT KEYWORD_SET(N) THEN N=10

is = REVERSE(SORT(st.val))
FOR i=0,N DO BEGIN
  PRINT,"Value = ",st[is[i]].val,' ==>  ',print_date(st[is[i]].jul,/SINGLE)
ENDFOR

END
