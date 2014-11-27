FUNCTION diff_tgeomat, geo1,geo2, cplx=cplx, verbose=verbose, _EXTRA=_EXTRA
; calcul la difference de geomat de type tide (tgeomat) 
; retourne une structure de type tgeomat contenant les différences d'amplitude et phase
; si /CPLX : retourne la différence complexe dans uns structure de type geomat, EN CENTIMETRES !!!

IF KEYWORD_SET(VERBOSE) THEN BEGIN
    PRINT, 'Difference between tidal amplitude and phase of  '+geo1.info+'  and  '+geo2.info
ENDIF

geo_interpolate, geo1, geo2, geo1_interp, geo2_interp, verbose=verbose

Nlon=N_ELEMENTS(geo1_interp.lon)
Nlat=N_ELEMENTS(geo1_interp.lat)
 
  ;creation de geocomp: difference entre geo1 et geo2 sur la grille de geo1
  
    ;(dA et dG)
    
  IF KEYWORD_SET(VERBOSE) THEN BEGIN
    print, '  Computing difference.....'
  ENDIF
    
IF NOT KEYWORD_SET(cplx) THEN BEGIN
  geocomp=create_geomat(Nlon, Nlat, /tide)
  geocomp.lon = geo1_interp.lon[*,0]
  geocomp.lat = geo1_interp.lat[*,0]

  dA=(geo1_interp.amp)-(geo2_interp.amp) 
  
  ; CAlcul de la différence de phase THETA
  costheta=(cos(!DTOR*geo1_interp.pha)*cos(!DTOR*geo2_interp.pha))+(sin(!DTOR*geo1_interp.pha)*sin(!DTOR*geo2_interp.pha))
  sintheta=(sin(!DTOR*geo1_interp.pha)*cos(!DTOR*geo2_interp.pha))-(sin(!DTOR*geo2_interp.pha)*cos(!DTOR*geo1_interp.pha))
  
  ;sinpos = WHERE((sintheta GE 0.) AND (sintheta EQ sintheta), cntpos)
  ;sinneg = WHERE((sintheta LT 0.) AND (costheta EQ costheta), cntneg)
  nan    = WHERE(sintheta NE sintheta, cntnan)

  
  dG=FLTARR(Nlon, Nlat)
  
  dG = ATAN(sintheta, costheta)*!RADEG
  
  ;IF (cntpos GT 0) THEN dG[sinpos]=ACOS(costheta[sinpos])*!RADEG
  ;IF (cntneg GT 0) THEN dG[sinneg]=-(ACOS(costheta[sinneg])*!RADEG)
  IF (cntnan GT 0) THEN dG[nan]=!VALUES.F_NAN

  
  ;dG=(geo1_interp.pha)-(geo2_interp.pha)
  
  geocomp.amp  = dA
  geocomp.pha  = dG
  geocomp.wave = geo1_interp.wave
  geocomp.info = geo1_interp.info+' - '+geo2_interp.info
  
  ; difference complexe
ENDIF ELSE BEGIN
  geocomp=create_geomat(Nlon, Nlat,/twoD)
  geocomp.lon = geo1_interp.lon[*,0]
  geocomp.lat = geo1_interp.lat[*,0]
  ;cplx1=COMPLEX(geo1_interp.amp*cos(rad(geo1_interp.pha)),geo1_interp.amp*sin(rad(geo1_interp.pha)))
  ;cplx2=COMPLEX(geo2.amp*cos(rad(geo2.pha)),geo2.amp*sin(rad(geo2.pha)))
  geocomp.val=ABS((COMPLEX(geo1_interp.amp*cos(rad(geo1_interp.pha)),geo1_interp.amp*sin(rad(geo1_interp.pha))))-COMPLEX(geo2_interp.amp*cos(rad(geo2_interp.pha)),geo2_interp.amp*sin(rad(geo2_interp.pha))))*100
  geocomp.info = geo1_interp.info+' - '+geo2_interp.info+'  (cplx difference)'
ENDELSE
  
  
  IF KEYWORD_SET(VERBOSE) THEN BEGIN
    print, '                          .....OK !'
  ENDIF

return, geocomp

  
END