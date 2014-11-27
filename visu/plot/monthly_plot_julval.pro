PRO monthly_plot_julval, st, tmin=tmin, tmax=tmax, yr=yr, ps=ps, png=png, nplot=nplot, $
                 output=output, _EXTRA=_EXTRA
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

;pos = [0.1,0.5,0.9,0.9]

; GESTION DU FORMAT DE SORTIE
; ---------------------------
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
        DEVICE, set_font='Times-Bold', /portrait, /color, filename=output, $
          font_size=16,$
          xsize=20, ysize=26,xoffset=0.,yoffset=0.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)          
    END
    KEYWORD_SET(png) : BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        DEVICE, retain=2, decomposed=1        
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE

; gestion de la date et de l'axe des temps
; ----------------------------------------
dmin = MIN(st.jul,/NAN,MAX=dmax)          ;calcul des dates min et max de la structure original
stm  = finite_st(monthly_mean(st,NMIN=2)) ;on calcul les moyennes mensuelles
Nmth = N_ELEMENTS(stm.jul)                ;nombre de mois de la serie
CALDAT,stm.jul,mm,dd,yy                   ;on decoupe la serie en tableaux mois/jour/an

choose_time_axis, ta='1j'        ;la valeur des label est fixee a 1j


IF NOT KEYWORD_SET(nplot) THEN nplot=3

;!P.MULTI = [Npage, 1, Nrows]
!P.MULTI = [0, 1, nplot,0,0]
!P.BACKGROUND = bck_col
!P.COLOR      = col

FOR i=0,Nmth-1 DO BEGIN
  dmin    = JULDAY(mm[i],1,yy[i],0,0,0)       ;on se cale au premier jour du mois
  st_plot = julcut(st,DMIN=dmin,DMAX=dmin+31) ;on decoupe la serie en tranche de 31 jours
  yra     = [MIN(st_plot.val,/NAN),MAX(st_plot.val,/NAN)] ;min & max sur le mois
  yst     = 1
  IF KEYWORD_SET(yr) THEN BEGIN
     yra=yr
     yst=1
  ENDIF
  PLOT, st_plot.jul, st_plot.val , /DATA, _EXTRA=_EXTRA, COLOR=col, $
      XRANGE = [dmin,dmin+31] ,XSTYLE=1,$
    YRANGE = yra, YSTYLE=yst
  
ENDFOR
tvlct, 255, 0, 0, (!D.TABLE_SIZE-2)

IF KEYWORD_SET(ps) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"PLOT_JULVAL write => ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"PLOT_JULVAL write => ",output
ENDIF

   ; Restore the previous plot and map system variables.
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map
;; Derniere Modif le 07/06/2007
END
