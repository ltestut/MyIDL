PRO plot_julval, st, st2, st3, st4, st5, tmin=tmin, tmax=tmax,  data_info=data_info, trend=trend, $
                 raxis=raxis, retv=retv, retn=retn, $ 
                 ps=ps, png=png,output=output, window=window, small=small, nplot=nplot, newplot=newplot,_EXTRA=_EXTRA
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

IF NOT KEYWORD_SET(nplot) THEN BEGIN
 !P.REGION=[0.01,0.4,0.90,0.90]
 IF KEYWORD_SET(data_info) THEN !P.REGION=[0.01,0.1,0.99,0.99]
ENDIF ELSE BEGIN
 !P.REGION=0
ENDELSE
; gestion du format de sortie
col           =  cgcolor('white',255) ;initialisation des couleurs de fond&premier plan 
bck_col       =  cgcolor('black',254)
IF NOT KEYWORD_SET(nplot) THEN nplot=1
output_format, col, bck_col, ps=ps, png=png, output=output, small=small


; gestion de la date et de l'axe des temps
dmin = MIN(st.jul,/NAN,MAX=dmax)                     ;calcul des dates min et max de la structure
date_label=default_time_axis(tmin, tmax, dmin, dmax) ;renvoie le date_label par defaut
choose_time_axis, _EXTRA=_EXTRA                      ;ecrase la valeur de date_label par defaut si ta='10mn' est present

!P.BACKGROUND = bck_col
!P.COLOR      = col
!P.MULTI      = [0,nplot,1,0,0]
IF KEYWORD_SET(raxis)  THEN !Y.STYLE=9 ELSE !Y.STYLE=1 
IF KEYWORD_SET(retv)   THEN !X.STYLE=9 ELSE !X.STYLE=1 
IF KEYWORD_SET(window) THEN WINDOW,window,_EXTRA=_EXTRA
PLOT, st.jul, st.val , /DATA, _EXTRA=_EXTRA, COLOR=col, $
  XRANGE        = [dmin,dmax] ,XSTYLE=1

;tvlct, 255, 0, 0, (!D.TABLE_SIZE-2)

; ajout de courbe supplementaire
IF (N_ELEMENTS(st2) GT 0) THEN BEGIN
 IF (KEYWORD_SET(raxis) AND (N_ELEMENTS(st3) EQ 0)) THEN BEGIN
 add_plot, st2, /raxis, color=cgcolor("red",253),PSYM=psym2,_EXTRA=_EXTRA
 ENDIF ELSE BEGIN
 add_plot, st2, color=cgcolor("red",253),PSYM=psym2,_EXTRA=_EXTRA
 ENDELSE
ENDIF 
; ajout de courbe supplementaire
IF (N_ELEMENTS(st3) GT 0) THEN BEGIN
 IF (KEYWORD_SET(raxis) AND (N_ELEMENTS(st4) EQ 0)) THEN BEGIN
 add_plot, st3, /raxis, color=cgcolor("blue",252),PSYM=psym2,thick=1.,_EXTRA=_EXTRA
 ENDIF ELSE BEGIN
 add_plot, st3, color=cgcolor("blue",252),PSYM=psym2,thick=1.,_EXTRA=_EXTRA
 ENDELSE
ENDIF 

; ajout de courbe supplementaire
IF (N_ELEMENTS(st4) GT 0) THEN BEGIN
 IF (KEYWORD_SET(raxis) AND (N_ELEMENTS(st5) EQ 0)) THEN BEGIN
 add_plot, st4, /raxis, color=cgcolor("green",251),PSYM=psym2,thick=1.
 ENDIF ELSE BEGIN
 add_plot, st4, color=cgcolor("green",251),PSYM=psym2,thick=1.
 ENDELSE
ENDIF 

; ajout de courbe supplementaire
IF (N_ELEMENTS(st5) GT 0) THEN BEGIN
 IF (KEYWORD_SET(raxis) AND (N_ELEMENTS(st6) EQ 0)) THEN BEGIN
 add_plot, st5, /raxis, color=cgcolor("orange",250),PSYM=psym2,thick=1.
 ENDIF ELSE BEGIN
 add_plot, st5, color=cgcolor("orange",250),PSYM=psym2,thick=1.
 ENDELSE
ENDIF 


; ajout de reticule de separation
IF KEYWORD_SET(retv) THEN BEGIN
 add_reticule, RETV=retv, RETN=retn, _EXTRA=_EXTRA
ENDIF

info     = info_st(st,tmin=tmin,tmax=tmax)
IF NOT KEYWORD_SET(data_info) THEN BEGIN
xinfo    = REPLICATE(0.1,N_ELEMENTS(info.str))
yinfo    = 0.35-FINDGEN(N_ELEMENTS(info.str))*0.05
XYOUTS,xinfo,yinfo,info.str,CHARSIZE=1.,/NORMAL,COLOR=col
ENDIF
IF KEYWORD_SET(trend) THEN BEGIN
 lin_fit  = info_st(st,tmin=tmin,tmax=tmax,/fit)
 OPLOT, st.jul, lin_fit, color=cgcolor("gray",254),thick=2.5,linestyle=1
ENDIF


IF KEYWORD_SET(ps) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
ENDIF
;print,'plot_julval  :',output
   ; Restore the previous plot and map system variables.
IF NOT KEYWORD_SET(nplot) THEN !P = bang_p
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map
;; Derniere Modif le 07/06/2007
print,!p.multi
END
