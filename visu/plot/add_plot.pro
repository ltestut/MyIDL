PRO add_plot, st, raxis=raxis, _EXTRA=_EXTRA
; ajoute une courbe sur le graph en cours 
; => /raxis sur l'axe de droite
yr = [MIN(st.val),MAX(st.val)]
print,yr
IF KEYWORD_SET(raxis) THEN BEGIN
   AXIS, YAXIS=1, YRANGE=yr,XSTYLE=4,YSTYLE=1,/SAVE 
   print,"raxis"
   OPLOT, st.jul, st.val, _EXTRA=_EXTRA
ENDIF ELSE BEGIN
   OPLOT, st.jul, st.val, _EXTRA=_EXTRA
ENDELSE 
END