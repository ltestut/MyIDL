PRO map_track_uv, lon, lat, u, v, limit=limit, zone=zone, verbose=verbose
; Programme pour tracer les donnees de courant le long d'une trace de bateau 

 ;save the current plot state
bang_p    = !P
bang_x    = !X
bang_Y    = !Y
bang_Z    = !Z
bang_Map  = !Map
bang_nlev = !ncol_map 

  ;init des parametres de sortie de la carte (ps, png, windows)
open_output_format,/VERBOSE,_EXTRA=_EXTRA

 ;tracage de la carte
POS = [0.1,0.1,0.9,0.8] ; position de la zone de tracage

 ;limite de tracage
IF (N_ELEMENTS(limit) EQ 0) THEN BEGIN
    g_limit=[min(lat),min(lon),max(lat),max(lon)] ;par defaut si pas de mot-cle
ENDIF ELSE BEGIN
    g_limit=[limit[2],limit[0],limit[3],limit[1]]                 ;limites definie par l'utilisateur [lon_min,lon_max,lat_min,lat_max]
ENDELSE
IF KEYWORD_SET(zone) THEN g_limit=use_zone(zone)            ;limite definie par une zone 
IF KEYWORD_SET(verbose) THEN BEGIN
  print,FORMAT='(A11,X,4(F7.3,A2))',"Limite geo=",g_limit[1],'E/',g_limit[3],'E/',g_limit[0],'N/',g_limit[2],'N'
ENDIF
ERASE                                                                        ; erase the windows


MAP_SET,/MERCATOR, /GRID, /NOERASE, /ISOTROPIC,  LIMIT=g_limit, POSITION=POS

MAP_CONTINENTS, /COASTS, /OVERPLOT, /FILL_CONTINENTS, MLINETHICK=0.5,$
                COLOR=FSC_Color('grey')

MAP_GRID,/BOX_AXES, LABEL=2
PLOTS,lon,lat, psym=1, $
      COLOR=cgcolor("gray",253), CLIP=POS, _EXTRA=_EXTRA

IF KEYWORD_SET(mark) THEN BEGIN
IF NOT KEYWORD_SET(footprint) THEN footprint=0.3
tvcircle, footprint, mark[0], mark[1], /FILL, /DATA, COLOR=cgcolor('black',252)
ENDIF


close_output_format,/verb,_EXTRA=_EXTRA

; Restore the previous plot and map system variables
; --------------------------------------------------
!P        = bang_p
!X        = bang_x
!Y        = bang_y
!Z        = bang_z
!Map      = bang_map
!ncol_map = bang_nlev

END