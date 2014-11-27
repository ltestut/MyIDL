PRO plot_monthly_histo, st, nval=nval, nday=nday, png=png, ps=ps, gauss=gauss, _EXTRA=_EXTRA
IF NOT KEYWORD_SET(nval) THEN     nval=6 ;moy pour au moins nval valeurs par jour
IF NOT KEYWORD_SET(nday) THEN     nday=1 ;moy pour au moins nday jours par mois
samp = (sampling_julval(st)/3600.) ;ech en heures

; GESTION DU FORMAT DE SORTIE
; ---------------------------
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map
col           =  cgcolor('white',255) 
bck_col       =  cgcolor('black',254)
CASE 1 OF
    (N_ELEMENTS(ps) EQ 0) AND (N_ELEMENTS(png) EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        device, retain=2, decomposed=0
        output='Xwindow'
    END
    KEYWORD_SET(ps) : BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
        IF NOT KEYWORD_SET(output) THEN output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        DEVICE, set_font='Times-Bold', /portrait, /color, /encapsulated, filename=output, $
          font_size=6,$
          xsize=14, ysize=6,xoffset=2.,yoffset=4.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
          
    END
    KEYWORD_SET(png) : BEGIN
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        DEVICE, retain=2, decomposed=1        
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE
!P.BACKGROUND = bck_col
!P.COLOR      = col

LOADCT,13,NCOLORS=12
stm = daily_mean(st   ,NVAL=nval)         ;calcul des moyennes journalieres

CALDAT,stm.jul,mm,dd,yy
; boucle de calcul des moyennes mensuelles a partir des moyennes journalieres
; ============================================================================
id         = WHERE(mm EQ 1,count)            ; recupere tous le premier mois 
id2        = WHERE(FINITE(stm[id].val),cval) ; nbre de valeur non nulles du premier mois
H          = stm[id[id2]].val
histo      = HISTOGRAM(H,LOCATIONS=X,_EXTRA=_EXTRA,/NAN)
histo      = FLOAT(histo)/FLOAT(MAX(histo))
sigma      = STDDEV(H,/NAN)
Z_std      = (X-MEAN(H,/NAN))/sigma ;variable centree reduite
gauss      = (1/SQRT(2*!PI))*exp(-((Z_std)^2)/2)
PLOT,x,histo/SQRT(2.*!pi),yrange=[0,0.6],xstyle=1,ystyle=1,psym=10,col=col,_EXTRA=_EXTRA
XYOUTS,0.15,0.95 ,'['+STRCOMPRESS(cval,/REMOVE_ALL)+']  month_'+$
                      STRCOMPRESS(1,/REMOVE_ALL)+' => Mean ='$
                     +STRING(MEAN(H,/NAN),FORMAT='(F8.2)'),/NORMAL,COLOR=col
XYOUTS,0.65,0.95,STRCOMPRESS(1,/REMOVE_ALL)+' => rms ='+STRING(sigma,FORMAT='(F5.2)'),/NORMAL,COLOR=col
IF KEYWORD_SET(gauss) THEN OPLOT,x,gauss,thick=3,COLOR=col


FOR i=1,11 DO BEGIN
   id         = WHERE(mm EQ (i+1),count)        ; recupere tous les mois de 1 a 12 
   id2        = WHERE(FINITE(stm[id].val),cval) ; nbre de valeur non nulles de chaque mois
   H          = stm[id[id2]].val
   sigma      = STDDEV(H,/NAN)
   histo      = HISTOGRAM(H,LOCATIONS=X,_EXTRA=_EXTRA,/NAN)
   histo      = FLOAT(histo)/FLOAT(MAX(histo))
   imax       = WHERE(histo EQ MAX(histo)) 
   Z_std      = (X-MEAN(H,/NAN))/sigma ;variable centree reduite
   gauss      = (1/SQRT(2*!PI))*exp(-((Z_std)^2)/2)
;   OPLOT,x,histo/SQRT(2.*!pi),psym=10,COLOR=i,THICK=2
XYOUTS,0.15,0.95-FLOAT(i)/50. ,'['+STRCOMPRESS(cval,/REMOVE_ALL)+']  month_'+STRCOMPRESS(i+1,/REMOVE_ALL)+' => Mean ='+STRING(MEAN(H,/NAN),FORMAT='(F8.2)'),/NORMAL,COLOR=i
XYOUTS,0.65,0.95-FLOAT(i)/50.,STRCOMPRESS(i+1,/REMOVE_ALL)+' => rms ='+STRING(STDDEV(H,/NAN),FORMAT='(F5.2)'),/NORMAL,COLOR=i
IF KEYWORD_SET(gauss) THEN OPLOT,x,gauss,thick=3,COLOR=i
ENDFOR

IF KEYWORD_SET(ps) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"PLOT_MONTHLY_HISTO write => ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"PLOT_MONTHLY_HISTO write => ",output
ENDIF

   ; Restore the previous plot and map system variables.
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map


END