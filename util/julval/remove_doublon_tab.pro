FUNCTION remove_doublon_tab, tab
; permet de flagger les doublons de valeurs d'un tableau de donnee
tab_diff= TS_DIFF(tab,1)
i_nd    = WHERE(ABS(tab_diff) GT 0.00001,count)
IF (count GT 0) THEN BEGIN
   print,"Nbre de non-doublon du tableau : ",count
   index=[i_nd,i_nd[count-1]+1]
   tab_new = tab[index] 
ENDIF ELSE BEGIN
   tab_new = tab[0]
ENDELSE
RETURN,tab_new
END