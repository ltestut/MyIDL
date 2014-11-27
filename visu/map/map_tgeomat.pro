
;FUNCTION read_scan, filename=filename
;; definition du patron de lecture
;tmp = {version:1.0,$
;       datastart:2   ,$
;       delimiter:' '   ,$
;       missingvalue:!VALUES.F_NAN   ,$
;       commentsymbol:'#'   ,$
;       fieldcount:3 ,$
;       fieldTypes:[3,4,4], $
;       fieldNames:['id','lon','lat'] , $
;        fieldLocations:[0,13,25], $
;        fieldGroups:indgen(3) $
;      }
;; lecture du fichier a partir du patron de lecture tmp
;data  = READ_ASCII(filename,TEMPLATE=tmp)
;st    = create_llval(N_ELEMENTS(data.lon),/NAN)
;st.lon = data.lon
;st.lat = data.lat
;RETURN, st
;END

pro map_tgeomat, geo_in, geo_in2, $
                  ps=ps, $
                  png=png, $
                  ncolors=ncolors, $
                  pal=pal, $
                  my_pal=my_pal, $
                  limit=limit, $
                  zone=zone, $
                  charsize=charsize, $
                  contour=contour, $
                  nlevels=nlevels, $
                  range_amp=range_amp, $
                  range_pha=range_pha, $
                  cst=cst, $
                  scan=scan, $
                  filename=filename, $
                  centered=centered, $
                  _EXTRA=_EXTRA 

; PROCEDURE qui trace une geostructure (GEO_IN)  de type marée : une carte d'amplitude et une carte de phase.
; par défaut la sortie est sur la sortie graphique, on peut spécifier /PS pour du postscript et /PNG pour du PNG
; pal=pal  : numéro de palette à utiliser (cf  )
; my_pal=my_pal : le nom de la palette à utiliser (par exemple la palette 'diff'; les noms de palette sont définis dans my_colortable)
; limit et zone permettent de faire un zoom
; nlevels définit le nombre de CONTOURS
; CENTERED pour avoir une palette de couleurs centree sur le zéro
; CST pour tracer la ligne de cote

; Save the current plot state
; ---------------------------
bang_p    = !P
bang_x    = !X
bang_Y    = !Y
bang_Z    = !Z
bang_Map  = !Map
bang_nlev = !ncol_map 


; LOAD DATA
;-----------------------------------------------------------
IF (N_PARAMS() EQ 2) THEN BEGIN
  geo_interpolate, geo_in, geo_in2, geo1, geo2
  geo=diff_tgeomat(geo_in, geo_in2, _EXTRA=_EXTRA) 
  geo.amp=100*geo.amp 
ENDIF ELSE BEGIN
  geo     = geo_in
  geo.amp = 100*geo.amp   ; PLOT IN CM !!
ENDELSE

IF KEYWORD_SET(scan) THEN BEGIN
scan=read_scan(filename=scan)
ENDIF

;READ KEYWORDS
;-----------------------------------------------------------
; CHARSIZE
  IF NOT KEYWORD_SET(charsize) THEN charsize=1
  
; FILENAME
  IF NOT KEYWORD_SET(filename) THEN filename='out'

;TITLE
  IF NOT KEYWORD_SET(title) THEN title='MODEL: '+geo.info+'    WAVE: '+geo.wave
  
;GEOGRAPHICAL LIMITS
  ;load zone if specified
  IF KEYWORD_SET(zone) THEN BEGIN
    limit=use_zone(zone=zone)
    limit=[limit[1],limit[3],limit[0],limit[2]]
  ENDIF
  
  ; read limits from the geo structure if nothing else is specified
  IF NOT (KEYWORD_SET(limit) OR KEYWORD_SET(zone)) THEN BEGIN
    minlon=MIN(geo.lon, /NAN, MAX=maxlon)
    minlat=MIN(geo.lat, /NAN, MAX=maxlat)  
    limit=[minlon,maxlon,minlat,maxlat]
  ENDIF
  
  ; cut geo struct
  print,"Limite geographique =",limit
  geo = geocut(geo, limit=limit)
  limit=[limit[2],limit[0],limit[3],limit[1]]   ; latmin/lonmin/latmax/lonmax  -> pour le map_set
;-----------------------------------------------------------------------------------

;DEFINE MIN MAX, MEAN
  ;compute min and max for appropriate scaling
  IF NOT KEYWORD_SET(range_pha) THEN BEGIN
    minpha    = MIN(geo.pha, /NAN, max=maxpha)
    range_pha = [minpha,maxpha]  
  ENDIF  
  IF NOT KEYWORD_SET(range_amp) THEN BEGIN
    minamp    = MIN(geo.amp, /NAN, max=maxamp)
    range_amp = [minamp,maxamp]     
  ENDIF
  
  ;compute mean amp and phase
  mean_amp = MEAN(geo.amp, /NAN)
  mean_pha = MEAN(geo.pha, /NAN)
;-----------------------------------------------------------------------------------

;COLORS
  ;Define color number      
    IF NOT KEYWORD_SET(ncolors)   THEN ncolors = 200
    bottom=0
  ;Define color table
    IF NOT ( KEYWORD_SET(pal) || KEYWORD_SET(my_pal))   THEN pal = 25
  ; Various Plot colors  
    white    = cgcolor('white', ncolors)
    black    = cgcolor('black', ncolors+1)
    gray     = cgcolor('gray', ncolors+2)
    magenta   = cgcolor('magenta', ncolors+3)
  ; color of missing data
    missing  = gray
  ; Load colors for display.
    !P.Background = white
    !P.Color      = black
    plot_color    = black
    plot_color_2  = magenta
  ; Load Color table
    erase
  
    IF KEYWORD_SET(my_pal)  THEN BEGIN
      my_colortable, my_pal, ncolors=ncolors
    ENDIF ELSE BEGIN
      loadct,pal, NCOLORS=ncolors, BOTTOM=bottom
    ENDELSE
;--------------------------------------------------------------------------------

  ; LEVELS FOR CONTOURS :
    IF NOT KEYWORD_SET(nlevels) THEN nlevels=ncolors-1+bottom
    
  ; POSTSCRIPT
    IF KEYWORD_SET(ps) THEN BEGIN
      old_font = !P.FONT
      !P.FONT  = 0
      rightsize = PSWINDOW(/CM)
      this_device = !D.name
      keywords = PSConfig(filename=filename+'.ps', _Extra=rightsize, /FONTINFO, /EUROPEAN, DIRECTORY=!idl_output)    
      SET_PLOT,'PS'
      device, _EXTRA=keywords
    ENDIF 


 ; tracé du titre principal:
 ;---------------------------------------------------------------------
   XYOUTS, 0.5, 0.95, title, /NORMAL, ALIGNMENT=0.5, COLOR=plot_color, CHARSIZE=1.8*charsize, FONT=fonttype

; FIRST PLOT : tide PHASE
  ; SET the position
    pos=[0.54,0.15,0.95,0.85]
  ; Set the MAP
    MAP_SET,/NOERASE, /MERCATOR, /ISOTROPIC, /NOBORDER, XMARGIN=[3,3], YMARGIN=[3,3], $
              LIMIT=limit, TITLE='Phase (deg) '+'   (mean='+STRCOMPRESS(STRING(mean_pha, FORMAT='(F5.1)'), /REMOVE_ALL)+')!C', $
              POSITION=pos, color=plot_color, CHARSIZE=1.3*charsize, _EXTRA=_EXTRA
   ; Scaling (scale all the values between MIN and MAX from 0 to TOP, Nan are set to 'missing')
   pha_scaled  = arrscl(geo.pha, min_value=range_pha[0], max_value=range_pha[1], top=(ncolors-1+bottom), missing=missing, centered=centered)
;  pha_scaled  = BYTSCL(geo.pha, MIN=range_pha[0], max=range_pha[1], TOP=ncolors ,/NAN)
    pha_img     = MAP_IMAGE(pha_scaled,x_offet, y_offset,xsize,ysize, MIN_VALUE=bottom-0.1, MAX_VALUE=(ncolors-1+bottom+0.1), COMPRESS=1, LONMIN=limit[1], LONMAX=limit[3], LATMIN=limit[0], LATMAX=limit[2], mask=mask_pha, MISSING=0, SCALE=0.5)
    flag        = WHERE(mask_pha EQ 0,cnt)
    IF (cnt GT 0 ) THEN pha_img[flag] = missing
    
  ;DISPLAY on TV 
    tv,pha_img, x_offet, y_offset, XSIZE=xsize,YSIZE=ysize
  ; display the geographical grid
    MAP_GRID,/BOX_AXES,  _EXTRA=_EXTRA, COLOR=plot_color, CHARSIZE=1.3*charsize, FONT=fonttype
    
    IF (N_PARAMS() EQ 2) THEN BEGIN
      IF KEYWORD_SET(contour) THEN BEGIN
        pha_scaled_1 = arrscl(geo1.pha, min_value=MIN(geo1.pha, /NAN), max_value=MAX(geo1.pha, /NAN), top=(ncolors-1+bottom), missing=missing, centered=centered)
        CONTOUR, pha_scaled_1, geo.lon, geo.lat, MAX_VALUE=(ncolors-1+bottom), /OVERPLOT, NLEVELS=nlevels, COLOR=plot_color, _EXTRA=_EXTRA
        pha_scaled_2 = arrscl(geo2.pha, min_value=MIN(geo2.pha, /NAN), max_value=MAX(geo2.pha, /NAN), top=(ncolors-1+bottom), missing=missing, centered=centered)
        CONTOUR, pha_scaled_2, geo.lon, geo.lat, MAX_VALUE=(ncolors-1+bottom), /OVERPLOT, NLEVELS=nlevels, color=plot_color_2, _EXTRA=_EXTRA
      ENDIF
    ENDIF ELSE BEGIN
      IF KEYWORD_SET(contour) THEN CONTOUR, pha_scaled, geo.lon, geo.lat, MAX_VALUE=(ncolors-1+bottom), /OVERPLOT, NLEVELS=nlevels, color=plot_color
    ENDELSE
    
    IF KEYWORD_SET(cst) THEN MAP_CONTINENTS,  /COASTS, /HIRES
    
    IF KEYWORD_SET(scan) THEN PLOTS, scan.lon, scan.lat, psym=0, COLOR=plot_color, CLIP=POS
    
    pos=[0.54,0.05,0.95,0.08]  
    IF KEYWORD_SET(centered) THEN BEGIN
      max_abs   = ABS(range_pha[0]) > ABS(range_pha[1])
      range_pha = [-max_abs,max_abs]
    ENDIF
      
    COLORBAR, ncolors=ncolors, range=range_pha, POSITION=pos, color=plot_color, FORMAT='(F8.1)', charsize=1.3*charsize, _EXTRA=_EXTRA

 ;SECOND PLOT : tide amplitude
    pos=[0.05,0.15,0.46,0.85]

    MAP_SET, /NOERASE, /MERCATOR, /ISOTROPIC, /NOBORDER, XMARGIN=[3,3], YMARGIN=[3,3], LIMIT=limit, TITLE='Amplitude (cm) '+'   (mean='+STRCOMPRESS(STRING(mean_amp, FORMAT='(F5.1)'), /REMOVE_ALL)+')!C', POSITION=pos, color=plot_color, CHARSIZE=1.3*charsize

    amp_scaled  = arrscl(geo.amp, min_value=range_amp[0], max_value=range_amp[1], top=(ncolors-1+bottom), missing=missing, centered=centered)
    amp_img     = MAP_IMAGE(amp_scaled,x_offet, y_offset,xsize,ysize,MIN_VALUE=bottom-0.1, MAX_VALUE=(ncolors-1+bottom+0.1), COMPRESS=1, LONMIN=limit[1], LONMAX=limit[3], LATMIN=limit[0], LATMAX=limit[2], mask=mask_amp, MISSING=0, SCALE=0.5)
    flag        = WHERE(mask_amp EQ 0,cnt)
    IF (cnt GT 0) THEN amp_img[flag] = missing
    tv,amp_img, x_offet, y_offset, XSIZE=xsize,YSIZE=ysize
    MAP_GRID,/BOX_AXES,  _EXTRA=_EXTRA, color=plot_color, CHARSIZE=1.3*charsize
    
    IF KEYWORD_SET(contour) THEN CONTOUR, amp_scaled, geo.lon, geo.lat, /OVERPLOT, NLEVELS=nlevels, color=plot_color
    IF KEYWORD_SET(cst) THEN MAP_CONTINENTS,  /COASTS, /HIRES
    IF KEYWORD_SET(scan) THEN PLOTS, scan.lon, scan.lat, psym=0, COLOR=plot_color, CLIP=POS
    
    pos=[0.05,0.05,0.46,0.08]
    IF KEYWORD_SET(centered) THEN BEGIN
      max_abs   = ABS(range_amp[0]) > ABS(range_amp[1])
      range_amp = [-max_abs,max_abs]
    ENDIF
     
    COLORBAR, ncolors=ncolors, range=range_amp, POSITION=pos, COLOR=plot_color, FORMAT='(F5.1)', charsize=1.3*charsize, _EXTRA=_EXTRA


 ; CLOSE THE PS file and Display with GV
  IF KEYWORD_SET(ps) THEN BEGIN 
    !P.FONT = old_font
    ;PS_END, /PNG
    device, /close_file
    set_plot, this_device
    ;spawn, 'gv '+!idl_output+'toto.ps'
  ENDIF

  IF KEYWORD_SET(png) THEN BEGIN
    toto=TVREAD(/PNG, FILENAME=!IDL_OUTPUT+filename, /NODIALOG)
 ;   spawn, 'display '+!idl_output+filename+'.png'
  ENDIF

; Restore the previous plot and map system variables
; --------------------------------------------------
!P        = bang_p
!X        = bang_x
!Y        = bang_y
!Z        = bang_z
!Map      = bang_map
!ncol_map = bang_nlev


END