FUNCTION remove_doublon, st, verbose=verbose
; permet de flagger les doublons de valeurs de temps dans les donnees
st1        = finite_st(st)
tab_diff   = TS_DIFF(st1.jul,1,/DOUBLE)
izero      = WHERE(ABS(tab_diff) LT 1E-6,count)
IF KEYWORD_SET(verbose) THEN BEGIN
   print,"Nbre de doublon de valeurs de temps (dt < 10Hz) : ",count
   print,print_date(st1[izero].jul)
ENDIF
IF (count GT 0) THEN BEGIN
   st1[izero].val=!VALUES.F_NAN 
ENDIF
st1 = finite_st(st1)
RETURN,st1
END