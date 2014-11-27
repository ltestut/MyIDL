PRO ploterr_julval, st, st2, st3, tmin=tmin, tmax=tmax,  raxis=raxis, data_info=data_info, mean_y=mean_y,$
                    retv=retv,retn=retn,hor=hor,$
                    ps=ps, png=png, output=output, ins=ins, trend=trend, window=window, small=small,_EXTRA=_EXTRA
;loadct,0
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

pos = [0.1,0.55,0.9,0.9]
IF KEYWORD_SET(data_info) THEN pos = [0.1,0.2,0.9,0.9]
 
; gestion du format de sortie
col           =  cgcolor('white',255) ;initialisation des couleurs de fond&premier plan 
bck_col       =  cgcolor('black',254)
output_format, col, bck_col, ps=ps, png=png, output=output, small=small


; gestion de la date et de l'axe des temps
dmin = MIN(st.jul,/NAN,MAX=dmax)                     ;calcul des dates min et max de la structure
date_label=default_time_axis(tmin, tmax, dmin, dmax) ;renvoie le date_label par defaut
choose_time_axis, _EXTRA=_EXTRA                      ;ecrase la valeur de date_label par defaut si ta='10mn' est present

info = info_st(st,tmin=tmin,tmax=tmax, _EXTRA=_EXTRA)
!P.BACKGROUND = bck_col
!P.COLOR      = col
!X.TICKLEN    = 1
!X.GRIDSTYLE  = 1   
IF KEYWORD_SET(raxis) THEN !Y.STYLE=8 ELSE !Y.STYLE=1     

choose_time_axis, _EXTRA=_EXTRA


print,print_date(dmin,/single)
print,print_date(dmax,/single)
ymax=MAX(st.val,/NAN)+MAX(st.rms)
ymin=MIN(st.val,/NAN)-MAX(st.rms)

IF KEYWORD_SET(window) THEN WINDOW,window
PLOT, st.jul, st.val , /DATA, _EXTRA=_EXTRA, COLOR=col, $
  XRANGE        = [dmin,dmax] ,YRANGE=[ymin,ymax], XSTYLE=1,$
  POSITION      =  pos
OPLOTERR, st.jul, st.val , st.rms,3
;ERRPLOT, st.val-st.rms,st.val+st.rms, COLOR=0
tvlct, 255, 0, 0, (!D.TABLE_SIZE-2)

; ajout de courbe supplementaire
IF (N_ELEMENTS(st2) GT 0) THEN BEGIN
 IF KEYWORD_SET(raxis) THEN BEGIN
 add_plot, st2, /raxis, color=cgcolor("red",253),PSYM=psym2,thick=1.
 ENDIF ELSE BEGIN
 add_plot, st2, color=cgcolor("red",253),PSYM=psym2,thick=1.
 ENDELSE
ENDIF 


IF (N_ELEMENTS(st3) GT 0) THEN OPLOT, st3.jul, st3.val, color=cgcolor("yellow",253),thick=1.5

; ajout de reticule de separation
IF KEYWORD_SET(retv) THEN BEGIN
 add_reticule, RETV=retv, RETN=retn, _EXTRA=_EXTRA
ENDIF

IF NOT KEYWORD_SET(data_info) THEN BEGIN
info     = info_st(st,tmin=tmin,tmax=tmax)
xinfo    = REPLICATE(0.1,N_ELEMENTS(info.str))
yinfo    = 0.35-FINDGEN(N_ELEMENTS(info.str))*0.05
XYOUTS,xinfo,yinfo,info.str,CHARSIZE=1.,/NORMAL,COLOR=col
   IF KEYWORD_SET(trend) THEN BEGIN
     lin_fit  = info_st(st,tmin=tmin,tmax=tmax,/fit)
     OPLOT, st.jul, lin_fit, color=cgcolor("red",254),thick=2.5
   ENDIF
ENDIF

!X.TICKLAYOUT   = 0 
!X.TICKINTERVAL = 0 
!X.TICKUNITS    = '' 
!X.TICKFORMAT   = '' 
!P.BACKGROUND   = 0
!P.COLOR        = 16777215


;; Derniere Modif le 07/06/2007
IF (KEYWORD_SET(ps) AND (N_ELEMENTS(ins) EQ 0)) THEN device, /close_file

;FIN : print,'OUTPUT ======>',output

IF KEYWORD_SET(ps) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF
; Restore the previous plot and map system variables.
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map;; Derniere Modif le 07/06/2007
END
