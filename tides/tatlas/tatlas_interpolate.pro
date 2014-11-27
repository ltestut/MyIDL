FUNCTION tatlas_interpolate, tatlas, lon=lon, lat=lat, $
                      wave=wave, $
                      verbose=verbose
; Interpolate a tide atlas on a new grid (lon,lat)
;  tatlas         : atlas to be interpolate 
;  lon,lat        : lon, lat grid where data need to be interpolated 
;  wave           : waves names to be interpolated

 ;gestion des mots-clefs et initialisation
IF NOT KEYWORD_SET(lon) THEN STOP,'tatlas2val : /!\ need lon and lat keyword'

 ;info on the size of the input structures 
nwaves     = N_ELEMENTS(tatlas.wave)
ntags      = N_TAGS(tatlas)
ntags_wave = N_TAGS(tatlas.wave)

IF NOT KEYWORD_SET(wave) THEN BEGIN 
 Xa    = tatlas.wave.amp 
 Xg    = tatlas.wave.pha
 wname = tatlas.wave.name
 iwave = INDGEN(N_ELEMENTS(wname))
ENDIF ELSE BEGIN
 wid   = -1                          ;wave index
 FOR i=0,N_ELEMENTS(wave)-1 DO BEGIN
  index = WHERE(tatlas.wave.name EQ wave[i],cpt)
  IF (cpt NE 1) THEN STOP,'/!\ wrong wave name ? '
  wid = [wid,index]
 ENDFOR
 iwave = wid[1:*]
 Xa    = tatlas.wave[iwave].amp
 Xg    = tatlas.wave[iwave].pha
 wname = tatlas.wave[iwave].name
ENDELSE     
nwa      = N_ELEMENTS(wname)  ;nbr d'onde a traiter

 ;create new atlas, copy new lon, lat and common fields 
tatlas_i     = create_tatlas(N_ELEMENTS(lon),N_ELEMENTS(lat),nwa)
tab_tags     = WHERE(TAG_NAMES(tatlas) NE 'LON' AND TAG_NAMES(tatlas) NE 'LAT' AND TAG_NAMES(tatlas) NE 'WAVE',cpt)
FOR i=0,cpt-1 DO tatlas_i.(tab_tags[i]) = tatlas.(tab_tags[i])
tatlas_i.info = '(interpolated) '+tatlas_i.info
tatlas_i.lon = lon
tatlas_i.lat = lat

;################################################################################
IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,FORMAT="('INPUT ATLAS DEFINITION                    : ',A-45)",tatlas.info
 PRINT,FORMAT="('  -> Nlon x Nlat [total wave/ used waves] : ',I4,' x',I4,' [',I3,'/',I3,']')",$
              N_ELEMENTS(tatlas.lon),N_ELEMENTS(tatlas.lat),N_ELEMENTS(tatlas.wave.name),N_ELEMENTS(iwave)
 PRINT,FORMAT="('OUTPUT ATLAS DEFINITION                   : ',A-45)",tatlas_i.info
 PRINT,FORMAT="('  -> Nlon x Nlat [total wave/ used waves] : ',I4,' x',I4,' [',I3,'/',I3,']')",$
              N_ELEMENTS(tatlas_i.lon),N_ELEMENTS(tatlas_i.lat),N_ELEMENTS(tatlas_i.wave.name),N_ELEMENTS(iwave)
ENDIF
;################################################################################
FOR i=0,nwa-1 DO BEGIN
   ilon = igeo(tatlas.lon,lon)
   ilat = igeo(tatlas.lat,lat)
   tatlas_i.wave[i].amp  = INTERPOLATE(Xa[*,*,i],ilon,ilat,/GRID,MISSING=!VALUES.F_NAN) ;bilinear interp on new grid for amplitude
   tatlas_i.wave[i].pha  = INTERPOLATE(Xg[*,*,i],ilon,ilat,/GRID,MISSING=!VALUES.F_NAN) ;bilinear interp on new grid for phase
   tatlas_i.wave[i].name = wname[i]
   tatlas_i.wave[i].filename = tatlas.wave[iwave[i]].filename
ENDFOR

RETURN,tatlas_i
END