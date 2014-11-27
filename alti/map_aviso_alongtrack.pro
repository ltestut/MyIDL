PRO map_aviso_alongtrack, lat, lon, val, zone=zone
; tg=tg, num=num, cor=cor, rms=rms, trend=trend, fscale=fscale,zone=zone,$
;               zrange=zrange, output=output, ps=ps, png=png, legend=legend,_EXTRA=_EXTRA
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

; GESTION DU FORMAT DE SORTIE
; ---------------------------
open_output_format

X_output=(KEYWORD_SET(ps)+KEYWORD_SET(png))
CASE 1 OF
    (X_output EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        device, retain=2, decomposed=0
        output='Xwindow'
        col           =  cgcolor('white',255) 
        bck_col       =  cgcolor('black',254)
    END
    KEYWORD_SET(ps) : BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
        ;output  =  'idl.ps'
        output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        device, set_font='Times-Bold', /portrait, /color, filename=output, $
          font_size=6,$
          xsize=14, ysize=6,xoffset=2.,yoffset=4.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
    KEYWORD_SET(png) : BEGIN
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        DEVICE, retain=2, decomposed=0  
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE
!P.BACKGROUND = bck_col
!P.COLOR      = col

IF NOT KEYWORD_SET(fscale) THEN fscale=100.
footprint = ((1./111.)*fscale)


; limite geographique de la structure & zoom
; ------------------------------------------
lat_min = MIN(lat,/NAN,MAX=lat_max)
lon_min = MIN(lon,/NAN,MAX=lon_max)
limit   = [lat_min,lon_min,lat_max,lon_max]
IF KEYWORD_SET(zone) THEN limit=zone_track(zone)

print,"Limite de la zone : ",limit


MAP_SET, /MERCATOR, /ISOTROPIC, /GRID, $
         POSITION=[0.1,0.16,0.9,0.9], LIMIT=limit,_EXTRA=_EXTRA ;, /NOERASE
MAP_CONTINENTS, /COASTS, /OVERPLOT, $
               FILL_CONTINENTS=2, LIMIT=limit, COLOR=cgcolor("grey",253), ORIENTATION=45
MAP_GRID,/BOX_AXES,LABEL=2

;MAP_GRID,LABEL=1,LATLAB=MIN(stx_plot.lon),LONLAB=MIN(stx_plot.lat),ORIENTATION=45.,/CLIP_TEXT

IF KEYWORD_SET(tg) THEN BEGIN
   tg_na=tg_name()
   FOR i=0,N_ELEMENTS(tg_na)-1 DO BEGIN
      tvcircle, footprint, tg_na[i].lon, tg_na[i].lat, /FILL, /DATA, COLOR=cgcolor('yellow',252), /LINE_FILL, SPACING=0.05, ORIENTATION=45.
      XYOUTS, tg_na[i].lon, tg_na[i].lat, tg_na[i].name,  /DATA
   ENDFOR   
ENDIF


;PLOTS,lon, lat, psym=3, COLOR=cgcolor("red",253), _EXTRA=_EXTRA


NCL=50
PAL=13
zval = val
LOADCT,PAL,NCOLORS=NCL
zmax=MAX(zval,/NAN) & zmin=MIN(zval,/NAN)
zrange=[zmin,zmax]
scl   = FLOAT(NCL)/(zrange[1]-zrange[0])
izval = (zval-zrange[0])*scl 
inan  = WHERE((izval LT 0) OR (izval GT NCL), count)
IF (count GT 0) THEN izval[inan]=!VALUES.F_NAN
tvcircle, footprint, lon, lat, izval,/DATA, /FILL
colorbar,POSITION=[0.15,0.1,0.85,0.15],ncolors=NCL,range=zrange,FORMAT='(F8.2)',/VERTICAL
print,"Total value [Min/Max]  = [",STRCOMPRESS(zmin,/REMOVE_ALL),"/",STRCOMPRESS(zmax,/REMOVE_ALL),"]"


; fermeture de fichier
; --------------------
IF KEYWORD_SET(ps) THEN device, /close_file               ; on ferme le fichier PostScript
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN  ; on ecrit un .png sans boite de dialog dans le fichier de sortie output 
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN                 ; on ecrit le .png avec ouverture d'une boite de dialog
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF


   ; Restore the previous plot and map system variables.
!P      = bang_p
!X      = bang_x
!Y      = bang_y
!Z      = bang_z
!Map    = bang_map

END