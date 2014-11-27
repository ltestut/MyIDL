PRO add_reticule, retv=retv, retn=retn, hor=hor,_EXTRA=_EXTRA
; ajoute d'un systeme de reticule sur l'axe verticale ou horizontale d'un plot_julval 
; => retv=[JULDAY(1,1,2000),10.,...] valeur 
; => retn=['New thali','toto',...]   nom des reticule 
; => /hor appliquer sur l'horizontale

IF NOT KEYWORD_SET(retn) THEN retn=STRCOMPRESS(retv)

IF KEYWORD_SET(hor) THEN BEGIN
 AXIS, YAXIS=1,/DATA, YTICKLEN=1,YTICKS=(N_ELEMENTS(retv)-1) , $
       YTICKV=retv , YTICKNAME=retn
ENDIF ELSE BEGIN
 AXIS, XAXIS=1, XTICKLEN=1,XTICKS=(N_ELEMENTS(retv)-1) , $
       XTICKFORMAT   = '', XTICKLAYOUT   = 0, XTICKUNITS    = '', $
       XTICKINTERVAL = 0, XMINOR=0,$
       XTICKV=retv , XTICKNAME=retn, $
       XTHICK=2., XGRIDSTYLE=2, XCHARSIZE=1.,$
       COLOR=cgcolor('magenta',250)
ENDELSE 
END