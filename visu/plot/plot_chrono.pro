PRO plot_chrono, filename=filename, png=png, ps=ps, tmin=tmin, tmax=tmax, output=output,_EXTRA=_EXTRA

;IF (N_PARAMS() EQ 0) THEN BEGIN
;    print, 'UTILISATION:'
;    print, 'gantt, filename=filename, /png, /ps, tmin=tmin, tmax=tmax, _EXTRA=_EXTRA"
;    print, ''
;    RETURN
;ENDIF
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map
col           =  cgcolor('white',255) 
bck_col       =  cgcolor('black',254)


IF NOT KEYWORD_SET(filename) THEN filename=!toto


; GESTION DU FORMAT DE SORTIE
; ---------------------------
CASE 1 OF
    (N_ELEMENTS(ps) EQ 0) AND (N_ELEMENTS(png) EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        DEVICE, retain=2, decomposed=0
        DEVICE, SET_CHARACTER_SIZE=[8,8]
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
        output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        device, set_font='Times-Bold', /portrait, /color, filename=output, $
          font_size=6,$
          xsize=14, ysize=6,xoffset=2.,yoffset=4.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
          
    END
    KEYWORD_SET(png) : BEGIN
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        !P.FONT=0
        DEVICE, retain=2, decomposed=1        
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE

; INFORMATION SUR LA GESTION DES COULEURS
; ---------------------------------------
Device, Get_Decomposed=theDecomposedState, Get_Visual_Depth=theDepth


; lecture du fichier chrono
; -------------------------
trm=  { version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:6L ,$
        fieldTypes:[4,7,7,7,7,4], $
        fieldNames:['num','deb','fin','name','color','deg'] , $
        fieldLocations:[0,3,24,44,64,75]    , $
        fieldGroups:INDGEN(6) $
      }
data  = READ_ASCII(filename,TEMPLATE=trm)

; transformation des dates
; ------------------------
N    = N_ELEMENTS(data.deb) & deb  = DBLARR(N) &  fin = DBLARR(N)  
raw  = data.num
name = data.name
coul = data.color 
deg  = data.deg 
READS,data.deb[0:N-1],deb,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
READS,data.fin[0:N-1],fin,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
dmin = MIN(deb)<MIN(fin) & dmax = MAX(deb)>MAX(fin) 
print,print_date(dmin)
print,print_date(dmax)
print,min(raw),max(raw)

; gestion de la date et de l'axe des temps
; ----------------------------------------
;print,print_date(dmin,/single)
;print,print_date(dmax,/single)
date_label=default_time_axis(tmin, tmax, dmin, dmax) ;renvoie le date_label par defaut
choose_time_axis, _EXTRA=_EXTRA  , layout=2          ;ecrase la valeur de date_label par defaut si ta='10mn' est present
PLOT, deb, raw , /DATA, /NODATA, _EXTRA=_EXTRA, $
  XRANGE        = [dmin,dmax] , YRANGE        = [MIN(raw-1),MAX(raw)+1] ,$ 
  XSTYLE=1,    YSTYLE=4       ,$
;  XTICKS        = 0    ,$
  XTICKLEN      = 1    ,$
  XGRIDSTYLE    = 1    ,$
  COLOR         = col ,$
  BACKGROUND    = bck_col ,$
  POSITION      = [0.2,0.2,0.8,0.8]
  
delta=0.05*MAX(raw,/NAN)
FOR i=0,N-1 DO BEGIN
POLYFILL, [deb[i], fin[i],fin[i], deb[i]], $
          [raw[i], raw[i],  raw[i]+delta, raw[i]+delta],/DATA,COLOR=cgcolor(coul[i],253-i),/CLIP
XYOUTS, fin[i], raw[i], name[i], SIZE=2, ORIENTATION=deg[i], COLOR=col
          
ENDFOR

IF KEYWORD_SET(ps) THEN BEGIN
print,output
device, /close_file
ENDIF
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
!Map = bang_map
END
