PRO map_track, stx,  lat=lat, lon=lon,  zoom=zoom, tg=tg, num=num, cor=cor, rms=rms, trend=trend, fscale=fscale,zone=zone,$
               zrange=zrange, output=output, ps=ps, png=png, legend=legend,_EXTRA=_EXTRA
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

IF NOT KEYWORD_SET(fscale) THEN fscale=1.
footprint = ((1./111.)*fscale)


; limite geographique de la structure & zoom
; ------------------------------------------
lat_min = MIN(stx.lat,/NAN,MAX=lat_max)
lon_min = MIN(stx.lon,/NAN,MAX=lon_max)
limit   = [lat_min,lon_min,lat_max,lon_max]
IF (N_ELEMENTS(zoom) EQ 4) THEN BEGIN
    limit    = [zoom[2],zoom[0],zoom[3],zoom[1]]
    stx_plot = cut_track(stx,limit=zoom) 
    ENDIF ELSE BEGIN
    stx_plot = stx
ENDELSE
IF KEYWORD_SET(zone) THEN limit=zone_track(zone)

print,"Limite de la zone : ",limit


MAP_SET, /MERCATOR, /ISOTROPIC, /GRID, POSITION=[0.1,0.16,0.9,0.9], LIMIT=limit,_EXTRA=_EXTRA ;, /NOERASE
MAP_CONTINENTS, /COASTS, /OVERPLOT, /HIRES, FILL_CONTINENTS=2, LIMIT=limit, COLOR=cgcolor("grey",253), ORIENTATION=45
MAP_GRID,/BOX_AXES,LABEL=2

;MAP_GRID,LABEL=1,LATLAB=MIN(stx_plot.lon),LONLAB=MIN(stx_plot.lat),ORIENTATION=45.,/CLIP_TEXT

IF KEYWORD_SET(tg) THEN BEGIN
   tg_na=tg_name()
   FOR i=0,N_ELEMENTS(tg_na)-1 DO BEGIN
      tvcircle, footprint, tg_na[i].lon, tg_na[i].lat, /FILL, /DATA, COLOR=cgcolor('yellow',252), /LINE_FILL, SPACING=0.05, ORIENTATION=45.
      XYOUTS, tg_na[i].lon, tg_na[i].lat, tg_na[i].name,  /DATA
   ENDFOR   
ENDIF

NCL=50
PAL=13
IF KEYWORD_SET(cor)   THEN zval = stx_plot.cor
IF KEYWORD_SET(rms)   THEN zval = stx_plot.rms
IF KEYWORD_SET(trend) THEN zval = stx_plot.trend

IF (KEYWORD_SET(cor) OR KEYWORD_SET(rms) OR KEYWORD_SET(trend)) THEN BEGIN
   LOADCT,PAL,NCOLORS=NCL
   zmax=MAX(zval,/NAN) & zmin=MIN(zval,/NAN)
   IF NOT KEYWORD_SET(zrange) THEN zrange=[zmin,zmax]
   scl   = FLOAT(NCL)/(zrange[1]-zrange[0])
   izval = (zval-zrange[0])*scl 
   inan  = WHERE((izval LT 0) OR (izval GT NCL), count)
      IF (count GT 0) THEN izval[inan]=!VALUES.F_NAN
   tvcircle, footprint, stx_plot.lon, stx_plot.lat, izval,/DATA, /FILL
   ;FOR i=0,N_ELEMENTS(izval)-1 DO print,i,zval[i],izval[i]
   colorbar,POSITION=[0.15,0.1,0.85,0.15],ncolors=NCL,range=zrange,FORMAT='(F8.2)',/VERTICAL,TITLE=legend
   print,"Total value [Min/Max]  = [",STRCOMPRESS(zmin,/REMOVE_ALL),"/",STRCOMPRESS(zmax,/REMOVE_ALL),"]"
   IF KEYWORD_SET(num) THEN FOR i=0,N_ELEMENTS(stx_plot.lat)-1  $ 
      DO XYOUTS, stx_plot[i].lon, stx_plot[i].lat, STRING(zval[i],FORMAT='(F8.2)'),/DATA
ENDIF ELSE BEGIN
PLOTS,stx_plot.lon, stx_plot.lat, psym=1, COLOR=cgcolor("red",253), _EXTRA=_EXTRA
ENDELSE

IF (KEYWORD_SET(num) AND NOT KEYWORD_SET(cor) AND NOT KEYWORD_SET(rms) AND NOT KEYWORD_SET(trend)) $
    THEN FOR i=0,N_ELEMENTS(stx.lat)-1 DO XYOUTS, stx[i].lon, stx[i].lat, STRCOMPRESS(STRING(i),/REMOVE_ALL),/DATA

IF (KEYWORD_SET(lat) AND KEYWORD_SET(lon)) THEN PLOTS, lon, lat, PSYM=1, SYMSIZE=4, COLOR=cgcolor("red",253) ; Rajout NP 12/06/2009


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