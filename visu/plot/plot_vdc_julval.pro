PRO plot_vdc_julval, sty0, sty, subarr=subarr, sm=sm, pal=pal, ps=ps, png=png, Nbin=Nbin, rpr=rpr, footprint=footprint, trend=trend,$
                     file_out=file_out, output=output, _EXTRA=_EXTRA
                     
; Decomposed color off if device supports it.
; ------------------------------------------
;CASE  StrUpCase(!D.NAME) OF
;    'X': BEGIN
;        Device, Get_Decomposed=thisDecomposed
;        Device, Decomposed=0
;    ENDCASE
;    'WIN': BEGIN
;        Device, Get_Decomposed=thisDecomposed
;        Device, Decomposed=0
;    ENDCASE
;    ELSE:
;ENDCASE

IF (N_ELEMENTS(sm) EQ 0) THEN sm=0
IF NOT KEYWORD_SET(pal) THEN pal=13
LOADCT, pal
IF (N_ELEMENTS(rpr) EQ 0) THEN rpr='time'
IF (N_ELEMENTS(footprint) EQ 0) THEN footprint=1.

; synchronisation des deux series
synchro_julval, sty0, sty, sty1, sty2, _EXTRA=_EXTRA
std    = rms_diff_julval(sty0,sty)
rcdiff = LINFIT(std.jul,std.val,SIGMA=err_diff,YFIT=lin_fit)

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
;fft_st_dvp,err ,errs  ; Calcul de la FFT de l'erreur de mesure
;fft_st_dvp,sty0,sty0f ; Calcul de la FFT du signal etalon
;fft_st_dvp,sty ,styf  ; Calcul de la FFT du signal a qualifie

; Calcul de la correlation et de la difference rms
; ------------------------------------------------
r_coef   = LINFIT(Y0,Y)                       ; Coefficient de regression entre l'etalon et le mrg 
r2_coef  = LINFIT(Y0,SMOOTH(DY,sm))           ; Coefficient de regression entre l'etalon et la difference (pente de vdc = erreur d'�chelle)
sigma    = stddev(SMOOTH(DY,sm),/NAN)
print,"NBRE DE DIFFERENCES UTILISEES     ", N_ELEMENTS(DY)
print,"CORRELATION DES 2 SIGNAUX         ", correlate(Y0,Y)
print,"MOYENNE DE LA DIFFERENCE (Y-Yref) ", mean(DY)
print,"   ===>  LE ZERO INSTRUMENTAL EST A ",STRCOMPRESS(STRING(mean(-1.*DY),FORMAT='(F8.3)'),/REMOVE_ALL), " DU ZERO DE LA REF"
print,"DIFFERENCE RMS DES 2 SIGNAUX      ",sigma,"  Cm"
print,"DROITE DE REGRESSION              ",r_coef[1] 
print,"ERREUR D'ECHELLE                  ",r2_coef[1]*100.

IF (KEYWORD_SET(file_out)) THEN BEGIN
 OPENW,  UNIT, file_out  , /GET_LUN        ;; ouverture en ecriture du fichier
 PRINTF, UNIT, "FICHIER RAPPORT DE PLOT_VDC_JULVAL"
 PRINTF, UNIT, "----------------------------------"
 PRINTF, UNIT,FORMAT='(A20,X,C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2))','Date de debut      :',sty1[0].jul     
 PRINTF, UNIT,FORMAT='(A20,X,C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2))','Date de fin        :',sty1[N_ELEMENTS(sty1.jul)-1].jul
 PRINTF, UNIT,FORMAT='(A20,X,I8)'  ,'Nbre diff utilisees:',N_ELEMENTS(DY)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Difference moyenne :',MEAN(sty0.val-sty1.val,/NAN)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Ecart-type de diff :',STDDEV(std.val)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Zi/Z_ref si(str,st):',MEAN(-1.*DY)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Moy serie rattach  :',MEAN(Y+MEAN(-1.*DY))
 PRINTF, UNIT,FORMAT='(A20,X,F8.2,X,A9,X,F6.2)','Tendance de diff   :',rcdiff[1]*3650.,'mm/yr +/-',err_diff[1]*3650.
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Corr. des signaux  :',CORRELATE(Y0,Y)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Droite de regress. :',r_coef[1]
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)',"Err. d'echelle     :",r2_coef[1]*100.
 CLOSE, UNIT
ENDIF
info  = "Cor="+STRING(CORRELATE(Y0,Y),format='(F8.6)')+" Mean_diff="+STRING(MEAN(DY),format='(F6.2)')+" Rms_diff="+STRING(sigma,format='(F4.2)')

; Calcul des indices de flux et reflux
; ------------------------------------
Id_flux   = WHERE(TS_DIFF(Y0,1 ) LT 0.,cpt_flux)
Id_reflux = WHERE(TS_DIFF(Y0,1 ) GT 0.,cpt_reflux)
info_flux  = "N_flux ="+STRING(cpt_flux)+ "  N_reflux ="+STRING(cpt_reflux)

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


;******************************************************************************
;                                PARTIE GRAPHIQUE
;******************************************************************************
; GESTION DU FORMAT DE SORTIE
; ---------------------------
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

CASE 1 OF
    (N_ELEMENTS(ps) EQ 0) AND (N_ELEMENTS(png) EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        device, retain=2, decomposed=0
        output='Xwindow'
    END
    KEYWORD_SET(ps) AND (N_ELEMENTS(ins) EQ 0): BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
        stack = SCOPE_TRACEBACK(/STRUCTURE)
        sourceDir = FILE_DIRNAME((stack[N_ELEMENTS(stack)-1]).filename,/MARK_DIRECTORY)
        sdir=STRSPLIT(sourceDir,'/',/EXTRACT)
        output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        device, set_font='Times-Bold', /portrait, /color, filename=output, $
          font_size=8,$
          xsize=12, ysize=5,xoffset=2.,yoffset=4.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)          
    END
    (N_ELEMENTS(ins) EQ 1): BEGIN
        output='insertion de plot_julval'
        IF (N_ELEMENTS(title) EQ 0) THEN title='POWER SPECTRAL DENSITY'        
    END
    KEYWORD_SET(png) : BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        DEVICE, retain=2, decomposed=1        
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE
!P.MULTI    = [0,2,3]
!P.FONT     = 2

lastcolor  = fsc_color("white",255)
lightcolor = fsc_color("grey",254)
hardcolor  = fsc_color("red",253)
flashcolor = fsc_color("yellow",252)

; Les 2 signaux
; ------------
PLOT ,Y0,TITLE="REFERENCE (noir) ET MESURE (gris)",XTITLE='Time',YSTYLE=1,THICK=2
OPLOT,Y ,color=lightcolor,psym=0

; La difference
; -------------
PLOT,Y0,LINESTYLE=2, TITLE="DIFFERENCE Y-Y0 (courbe rouge)", YTITLE="Y-Y0",XTITLE=info
tvcircle, footprint, INDGEN(N),Y0, BYTSCL(indgen(N),TOP=250),/DATA, /FILL
AXIS,1,0,YAXIS=0,/NORMAL,YRANGE=[-10.,10.],/SAVE
OPLOT,(DY-MEAN(DY,/NAN)),COLOR=hardcolor
OPLOT,SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE),COLOR=flashcolor

; DIAGRAMME DE VAN DE CASTEELE
; ----------------------------
CASE rpr OF 
    'time':BEGIN
        PLOT ,Y0,SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE),PSYM=3,YRANGE=[-2*sigma,2.*sigma],XTITLE="YO",YTITLE="Y-Y0"
        tvcircle, footprint, Y0, SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE),  BYTSCL(indgen(N),TOP=250),/DATA, /FILL
        XYOUTS,1.1*MIN(Y0),0.9*2.*sigma,"Erreur d'echelle ="+STRING(r2_coef[1]*100.,FORMAT='(F6.3)')+"%",CHARSIZE=1.,/DATA
    END
    'flux':BEGIN
        PLOT ,Y0,SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE),PSYM=3,YRANGE=[-2*sigma,2.*sigma],XTITLE="YO",YTITLE="Y-Y0"
        tvcircle, footprint, Y0[id_flux],   (SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE))[id_flux],    flashcolor ,/DATA, /FILL
        tvcircle, footprint, Y0[id_reflux], (SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE))[id_reflux],  lightcolor ,/DATA, /FILL
        XYOUTS,1.1*MIN(Y0),0.9*2.*sigma,"Erreur d'echelle ="+STRING(r2_coef[1]*100.,FORMAT='(F6.3)')+"%",CHARSIZE=1.,/DATA
        XYOUTS,1.1*MIN(Y0),0.8*2.*sigma,info_flux
    END
ENDCASE
        OPLOT,Y0,MAKE_ARRAY(N_ELEMENTS(Y0),VALUE=0.),COLOR=flashcolor,LINESTYLE=1
        OPLOT,Y0bin,DYbin,COLOR=lastcolor,THICK=5

; La droite de regression entre les deux signaux
; ----------------------------------------------
PLOT ,Y0, Y ,PSYM=3,Ystyle=1,Xstyle=1,XTITLE="YO",YTITLE="Y"
XYOUTS,1.1*MIN(Y0),0.9*MAX(Y),"Regr ="+STRING(r_coef[1]),CHARSIZE=1.,/DATA

plot_histo,(SMOOTH(DY-MEAN(DY,/NAN),sm,/EDGE_TRUNCATE)),binsize=0.1,TITLE="HISTOGRAMME DE LA DIFFERENCE"
plot,Y0bin,DYbin, TITLE="SCHEMA DE VDC MOYEN"
;plot_fft_dvp,sty0f,styf,/ins,tmin=2,tmax=10.*24.,tmark=[2,12,24,48],/xlog,/ylog
;plot_fft_dvp,errs,/ins,tmin=2,tmax=10.*24.,tmark=[2,12,24,48],/xlog

IF (KEYWORD_SET(ps) AND (N_ELEMENTS(ins) EQ 0)) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"PLOT_JULVAL write => ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"PLOT_JULVAL write => ",output
ENDIF
   ; Restore the previous plot and map system variables.
loadct,0
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map
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
IF  (KEYWORD_SET(file_out)) THEN FREE_LUN, UNIT
;; Derniere Modif le 11/02/2010
END
