; $Id: plot_histo.pro,v 1.00 01/05/2005 L. Testut $
;

;+
; NAME:
;	PLOT_HISTO
;
; PURPOSE:
;	Plot the histogram of a tab
;	
; CATEGORY:
;	Read/Write procedure/function
;
; CALLING SEQUENCE:
;	PLOT_HISTO,H
;	
; INPUTS:
;	
;
; OUTPUTS:
;	
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;
;-
;

PRO plot_histo, H, tab2=tab2,  SIGMA=sigma, png=png, ps=ps, output=output, _EXTRA=_EXTRA
; trace l'histogramme d'un tableau de valeur
; et superpose une distribution gaussienne de meme ecart-type
IF NOT KEYWORD_SET(sigma) THEN sigma=STDDEV(H,/NAN)
str_sig  = 'Sigma ='+STRCOMPRESS(STRING(sigma,FORMAT='(F8.3)'),/REMOVE_ALL)
str_mean = 'Mean  ='+STRCOMPRESS(STRING(MEAN(H),FORMAT='(F8.3)'),/REMOVE_ALL)

; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map


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
        stack = SCOPE_TRACEBACK(/STRUCTURE)
        sourceDir = FILE_DIRNAME((stack[N_ELEMENTS(stack)-1]).filename,/MARK_DIRECTORY)
        ; /MARK_DIRECTORY permet de placer un separateur de repertoire a la fin du chemin
        sdir=STRSPLIT(sourceDir,'/',/EXTRACT)
        ;dir='/'+sdir[0]+'/'
        ;print,'output_dir=',dir
        IF NOT KEYWORD_SET(output) THEN output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        DEVICE, set_font='Times-Bold', /portrait, /color, /encapsulated, filename=output, $
          font_size=6,$
          xsize=14, ysize=6,xoffset=2.,yoffset=4.
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


; Compute the normalized histogram of input vector/array H
; --------------------------------------------------------
histo  = HISTOGRAM(H,LOCATIONS=X,_EXTRA=_EXTRA,/NAN)
histo  = FLOAT(histo)/FLOAT(MAX(histo))
imax   = WHERE(histo EQ MAX(histo)) 
Z_std  = (X-MEAN(H,/NAN))/sigma ;variable centree reduite
gauss  = (1/SQRT(2*!PI))*exp(-((Z_std)^2)/2)


!P.BACKGROUND = bck_col
!X.TICKLEN    = 1
!X.GRIDSTYLE  = 1   
PLOT,x,histo/SQRT(2.*!pi),yrange=[0,0.5],xstyle=1,ystyle=1,psym=10,COLOR=col,THICK=3,_EXTRA=_EXTRA
OPLOT,x,gauss,thick=3,COLOR=col

;XYOUTS,0.15,0.85,str_sig,/NORMAL,COLOR=col
;XYOUTS,0.15,0.80,str_mean,/NORMAL,COLOR=col

IF KEYWORD_SET(tab2) THEN BEGIN
; Compute the normalized histogram of input vector/array H
; --------------------------------------------------------
histo2  = HISTOGRAM(tab2,LOCATIONS=x2,_EXTRA=_EXTRA,/NAN)
histo2  = FLOAT(histo2)/FLOAT(MAX(histo2))
OPLOT,x2,histo2/SQRT(2.*!pi),thick=1,psym=10,COLOR=col
ENDIF

FIN : print,'OUTPUT ======>',output
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

;!X.TICKLAYOUT   = 0 
;!X.TICKINTERVAL = 0 
;!X.TICKUNITS    = '' 
;!X.TICKFORMAT   = '' 
;!P.BACKGROUND   = 0


END
