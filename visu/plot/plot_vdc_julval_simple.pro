PRO plot_vdc_julval_simple, sty0, sty, sigma, subarr=subarr, sm=sm, pal=pal, ps=ps, png=png, Nbin=Nbin, footprint=footprint, xr=xr, trend=trend, _EXTRA=_EXTRA

; Decomposed color off if device supports it.
; ------------------------------------------
CASE  StrUpCase(!D.NAME) OF
    'X': BEGIN
        Device, Get_Decomposed=thisDecomposed
        Device, Decomposed=0
    ENDCASE
    'WIN': BEGIN
        Device, Get_Decomposed=thisDecomposed
        Device, Decomposed=0
    ENDCASE
    ELSE:
ENDCASE

IF (N_ELEMENTS(sm) EQ 0) THEN sm=0
IF (N_ELEMENTS(pal) EQ 1) THEN LOADCT,pal
IF (N_ELEMENTS(footprint) EQ 0) THEN footprint=1.

synchro_julval, sty0, sty, sty1, sty2, bs=60.

IF (N_ELEMENTS(subarr) EQ 0) THEN subarr=[0,N_ELEMENTS(sty1)-1]
IF KEYWORD_SET(trend) THEN BEGIN
   sty1 = remove_trend(sty1)
   sty2 = remove_trend(sty2)
ENDIF

Y0 = sty1[subarr[0]:subarr[1]].val
Y  = sty2[subarr[0]:subarr[1]].val 
DY = Y-Y0

;******************************************************************************
;                                PARTIE CALCUL
;******************************************************************************
; Calcul de l'erreur de mesure
; ----------------------------
N       = N_ELEMENTS(Y0)
X       = INDGEN(N)
err     = create_julval(N)
err.jul = sty1[subarr[0]:subarr[1]].jul
err.val = Y-Y0

; Calcul de la correlation et de la difference rms
; ------------------------------------------------
r_coef   = LINFIT(Y0,Y)                       ; Coefficient de regression entre l'etalon et le mrg 
r2_coef  = LINFIT(Y0,SMOOTH(DY,sm))           ; Coefficient de regression entre l'etalon et la difference (pente de vdc = erreur d'echelle)
sigma    = stddev(SMOOTH(DY,sm),/NAN)
print,"NBRE DE DIFFERENCES UTILISEES     ", N_ELEMENTS(DY)
print,"CORRELATION DES 2 SIGNAUX         ", correlate(Y0,Y)
print,"MOYENNE DE LA DIFFERENCE (Y-Yref) ", mean(DY)
print,"   ===>  LE ZERO INSTRUMENTAL EST A ",STRCOMPRESS(STRING(mean(-1.*DY),FORMAT='(F8.3)'),/REMOVE_ALL), " DU ZERO DE LA REF"
print,"DIFFERENCE RMS DES 2 SIGNAUX      ",sigma,"  Cm"
print,"DROITE DE REGRESSION              ",r_coef[1] 
print,"ERREUR D'ECHELLE                  ",r2_coef[1]*100.," %"
info  = "Cor="+STRING(CORRELATE(Y0,Y),format='(F8.6)')+" Mean_diff="+STRING(MEAN(DY),format='(F6.2)')+" Rms_diff="+STRING(sigma,format='(F4.2)')

; Calcul du vdc moyen
; -------------------
IF (N_ELEMENTS(Nbin) EQ 0) THEN Nbin  = 11 
step  = (MAX(Y0,/NAN)-MIN(Y0,/NAN))/Nbin
Y0bin = FLTARR(Nbin) & Y0bin = MIN(Y0,/NAN)+INDGEN(Nbin)*step
DYbin = MAKE_ARRAY(Nbin,VALUE=!VALUES.F_NAN)
FOR I=0,Nbin-2 DO BEGIN
    Ibin  = WHERE((Y0 GT Y0bin[I]) AND (Y0 LE Y0bin[I+1]),count)
    IF (count GE 1) THEN DYbin[I] = MEAN((SMOOTH(DY-MEAN(DY,/NAN),sm,/NAN))[Ibin])
ENDFOR
print,"STEP OF THE MEAN VDC               ",step


;******************************************************************************
;                                PARTIE GRAPHIQUE
;******************************************************************************
col           =  cgcolor('white',255) 
bck_col       =  cgcolor('black',254)
; GESTION DU FORMAT DE SORTIE
; ---------------------------
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
        stack = SCOPE_TRACEBACK(/STRUCTURE)
        sourceDir = FILE_DIRNAME((stack[N_ELEMENTS(stack)-1]).filename,/MARK_DIRECTORY)
        sdir=STRSPLIT(sourceDir,'/',/EXTRACT)
        output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        device, set_font='Times-Bold', /portrait, /color, filename=output, $
          font_size=6,$
          xsize=14, ysize=6,xoffset=2.,yoffset=4.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)          
    END
    KEYWORD_SET(png) : BEGIN
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        device, retain=2, decomposed=1        
        output = 'idl.png'  
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
   END
ENDCASE

; INFORMATION SUR LA GESTION DES COULEURS
; ---------------------------------------
Device, Get_Decomposed=theDecomposedState, Get_Visual_Depth=theDepth
print,'Decomposed State = ',theDecomposedState
!P.MULTI      = [0,2,1]
!P.FONT       = 2
!P.BACKGROUND = bck_col
!X.TICKLEN    = 1
!X.GRIDSTYLE  = 1   


;tvlct, 255, 0, 0, (!D.TABLE_SIZE-2)

; DIAGRAMME DE VAN DE CASTEELE
; ----------------------------
IF (N_ELEMENTS(xr) EQ 0) THEN xr=[-2*sigma,2.*sigma]
PLOT ,SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE),Y0,PSYM=1,XRANGE=xr,$
      XSTYLE=1, YSTYLE=1, COLOR=col, $
      YTITLE="SEA LEVEL HIGH",XTITLE="SEA LEVEL DIFFERENCE", _EXTRA=_EXTRA
;tvcircle, footprint, SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE),Y0,  BYTSCL(indgen(N),TOP=250),/DATA, /FILL
OPLOT,MAKE_ARRAY(N_ELEMENTS(Y0),VALUE=0.),Y0,color=cgcolor("gray",253),LINESTYLE=1
OPLOT,DYbin,Y0bin,color=cgcolor("red",252),THICK=5

; L'histogramme de la difference
; ------------------------------
IF KEYWORD_SET(png) THEN BEGIN
   plot_histo,(SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE)),binsize=0.1, XRANGE=xr, sigma=sigma, /png, _EXTRA=_EXTRA
ENDIF ELSE BEGIN 
   plot_histo,(SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE)),binsize=0.1, XRANGE=xr, sigma=sigma, _EXTRA=_EXTRA
ENDELSE
IF (KEYWORD_SET(ps) AND (N_ELEMENTS(ins) EQ 0)) THEN device, /close_file
IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=filename,/CANCEL,/PNG)
   ;WRITE_PNG, file_out, image , /VERBOSE 
   print,"Ecriture du fichier : ",filename
ENDIF
!P.MULTI=[0,1,1]

; Restore Decomposed state if necessary.
CASE StrUpCase(!D.NAME) OF
    'X': BEGIN
        Device, Decomposed=thisDecomposed
    ENDCASE
    'WIN': BEGIN
        Device, Decomposed=thisDecomposed
    ENDCASE
    ELSE:
ENDCASE

END
