PRO map_geomat, geo_in, $
                           frame=frame,$
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
                           range=range, $
                           global_scale=global_scale,$      ; une seule echelle de couleurs pour tous les pas de temps ( pour faire des animations ?)
                           cst=cst, $
                           filename=filename, $
                           centered=centered, $
                           verbose=verbose,$
                           info=info,$
                           _extra=_extra

; PROCEDURE qui trace une geostructure (GEO_IN)
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
geo     = geo_in



;READ KEYWORDS
;-----------------------------------------------------------
; CHARSIZE
  IF NOT KEYWORD_SET(charsize) THEN charsize=1
  
; FILENAME
  IF NOT KEYWORD_SET(filename) THEN filename='toto'


; TITLE
  IF NOT KEYWORD_SET(title) THEN title=geo.info
  
  
;GEOGRAPHICAL LIMITS
  ;load zone if specified
  IF KEYWORD_SET(zone) THEN BEGIN
    limit=use_zone(zone=zone)
    limit=[limit[1],limit[3],limit[0],limit[2]]
  ENDIF
  
  ; read limits in geo structure if nothing else if specified
  IF NOT (KEYWORD_SET(limit) OR KEYWORD_SET(zone)) THEN BEGIN
    minlon=MIN(geo.lon, /NAN, MAX=maxlon)
    minlat=MIN(geo.lat, /NAN, MAX=maxlat)  
    limit=[minlon,maxlon,minlat,maxlat]
  ENDIF
  
  ; cut geo struct
  IF KEYWORD_SET(verbose) THEN print,"Limite geographique =",limit
  geo = geocut(geo, limit=limit)
  limit=[limit[2],limit[0],limit[3],limit[1]]   ; latmin/lonmin/latmax/lonmax  -> pour le map_set
  
 ;---------------------------------------------------------------------------------
 ; FRAME NUMBER ?
  IF NOT KEYWORD_SET(frame) THEN frame=0
  date=''
  IF ( WHERE(TAG_NAMES(geo) EQ 'JUL') NE -1) THEN BEGIN
    date='   TIME : '+print_date(geo.jul[frame],/SINGLE)+'   '
  END
  
  title=title+date


;-----------------------------------------------------------------------------------
;DEFINE GLOBAL MIN MAX (for all time steps)
  ;compute min and max for appropriate scaling
  IF NOT KEYWORD_SET(range) AND KEYWORD_SET(global_scale) THEN BEGIN
    zmin    = MIN(geo.val, /NAN, max=zmax)
    range = [zmin,zmax]  
  ENDIF 

;-----------------------------------------------------------------------------------
;DEFINE frame MIN MAX
  ;compute min and max for appropriate scaling
  IF NOT KEYWORD_SET(range) AND NOT KEYWORD_SET(global_scale) THEN BEGIN
    zmin    = MIN(geo.val[*,*,frame], /NAN, max=zmax)
    range = [zmin,zmax]  
  ENDIF

;-----------------------------------------------------------------------------------
;MEAN
IF KEYWORD_SET(info) THEN BEGIN
  zmean = MEAN(geo.val[*,*,frame], /NAN)
  ;TITLE
  title=title+'   (mean='+STRCOMPRESS(STRING(zmean, FORMAT='(F5.1)'), /REMOVE_ALL)+' )'
 ENDIF
 
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
  ; color of missing data
    missing  = gray
  ; Load colors for display.
    !P.Background = white
    !P.Color      = black
    plot_color    = black
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
 ;  XYOUTS, 0.5, 0.95, title, /NORMAL, ALIGNMENT=0.5, COLOR=plot_color, CHARSIZE=1.8*charsize, FONT=fonttype

; FIRST PLOT : tide PHASE
  ; SET the position
    pos=[0.1,0.12,0.95,0.95]
  ; Set the MAP
    MAP_SET,/NOERASE, /MERCATOR, /ISOTROPIC, /NOBORDER, XMARGIN=[3,3], YMARGIN=[3,3], $
              LIMIT=limit, TITLE=title+' !C', $
              POSITION=pos, color=plot_color, CHARSIZE=1.3*charsize, _EXTRA=_EXTRA
   ; Scaling (scale all the values between MIN and MAX from 0 to TOP, Nan are set to 'missing')
   val_scaled  = arrscl(geo.val[*,*,frame], min_value=range[0], max_value=range[1], top=(ncolors-1+bottom), missing=missing, centered=centered)
   val_img     = MAP_IMAGE(val_scaled,x_offet, y_offset,xsize,ysize, MIN_VALUE=bottom-0.1, MAX_VALUE=(ncolors-1+bottom+0.1), COMPRESS=1, LONMIN=limit[1], LONMAX=limit[3], LATMIN=limit[0], LATMAX=limit[2], mask=mask, MISSING=0, /BILINEAR, SCALE=0.5)
    flag        = WHERE(mask EQ 0,cnt)
    IF (cnt GT 0 ) THEN val_img[flag] = missing
    
  ;DISPLAY on TV 
    tv,val_img, x_offet, y_offset, XSIZE=xsize,YSIZE=ysize
  ; display the geographical grid
    MAP_GRID,/BOX_AXES,  _EXTRA=_EXTRA, COLOR=plot_color, CHARSIZE=1.3*charsize, FONT=fonttype
    IF KEYWORD_SET(contour) THEN CONTOUR, val_scaled, geo.lon, geo.lat, MAX_VALUE=(ncolors-1+bottom), /OVERPLOT, NLEVELS=nlevels
    IF KEYWORD_SET(cst) THEN MAP_CONTINENTS,  /COASTS, /HIRES
    
    pos=[0.1,0.05,0.95,0.09]  
    IF KEYWORD_SET(centered) THEN BEGIN
      max_abs   = ABS(range[0]) > ABS(range[1])
      range = [-max_abs,max_abs]
    ENDIF
      
;    COLORBAR, ncolors=ncolors, BOTTOM=bottom, range=range, POSITION=pos, color=plot_color,  charsize=1.3*charsize, _EXTRA=_EXTRA



 ; CLOSE THE PS file and Display with GV
  IF KEYWORD_SET(ps) THEN BEGIN 
    !P.FONT = old_font
    ;PS_END, /PNG
    device, /close_file
    set_plot, this_device
    ;spawn, 'gv '+!idl_output+'toto.ps'
  ENDIF

  IF KEYWORD_SET(png) THEN BEGIN
    toto=TVREAD(/PNG, FILENAME=filename, /NODIALOG)
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