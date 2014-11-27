PRO geo_interpolate, input_geo1, input_geo2, geo1, geo2, verbose=verbose
;Procedure qui permet d'interpoler GEO2 sur la grille de GEO1 (geomat de type tide seulement, il manque quelques lignes pour pouvopir travailler sur les autres types de geomat !)

; RETOURNE DEUX GEOMAT grillées avec la même grille (celle de GEO1)

geo1=input_geo1
geo2=input_geo2

;Lecture des limites geographiques des deux geomat

  limites1 = get_geo_lim(geo1)   
  limites2 = get_geo_lim(geo2)
  IF KEYWORD_SET(verbose) THEN BEGIN 
    print, '  Interpolation of ' , geo2.info, '  on the grid of   ', geo1.info, '       ............'
    print, '   '
    print, '    limites geo1 : ', limites1 
    print, '    limites geo2 : ', limites2
    print, '  '
  ENDIF


;Definition de la zone commune
  lim_inter= get_geo_intersect(limites1, limites2) 
  IF KEYWORD_SET(VERBOSE) THEN print, '    zone commune : ', lim_inter


; calcul des delta lon lat
  delta_lon1=(limites1[1]-limites1[0])/(N_ELEMENTS(geo1.lon)-1)
  delta_lon2=(limites2[1]-limites2[0])/(N_ELEMENTS(geo2.lon)-1)
  delta_lat1=(limites1[3]-limites1[2])/(N_ELEMENTS(geo1.lat)-1)
  delta_lat2=(limites2[3]-limites2[2])/(N_ELEMENTS(geo2.lat)-1)
  
  IF KEYWORD_SET(VERBOSE) THEN BEGIN
    print, ' '
    print,'    delta lon/lat geo1 : ', [delta_lon1,delta_lat1]
    print,'    delta lon/lat geo2 : ', [delta_lon2,delta_lat2]
  ENDIF
  

;calcul des lon lat ou couper (limites communes + un pas de grille si possible)

  ilon1 = WHERE((geo1.lon GE (lim_inter[0]-delta_lon1)) AND (geo1.lon LE (lim_inter[1]+delta_lon1)))
  lon1_cut=[geo1.lon[ilon1[0]],geo1.lon[ilon1[N_ELEMENTS(ilon1)-1]]]
  ilon2 = WHERE((geo2.lon GE (lim_inter[0]-delta_lon2)) AND (geo2.lon LE (lim_inter[1]+delta_lon2)))
  lon2_cut=[geo2.lon[ilon2[0]],geo2.lon[ilon2[N_ELEMENTS(ilon2)-1]]]

  ilat1 = WHERE((geo1.lat GE (lim_inter[2]-delta_lat1)) AND (geo1.lat LE (lim_inter[3]+delta_lat1)))
  lat1_cut=[geo1.lat[ilat1[0]],geo1.lat[ilat1[N_ELEMENTS(ilat1)-1]]]
  ilat2 = WHERE((geo2.lat GE (lim_inter[2]-delta_lat2)) AND (geo2.lat LE (lim_inter[3]+delta_lat2)))
  lat2_cut=[geo2.lat[ilat2[0]],geo2.lat[ilat2[N_ELEMENTS(ilat2)-1]]]

  IF KEYWORD_SET(VERBOSE) THEN BEGIN
    print, ' '
    print, '    cut de geo1 : ',lon1_cut, lat1_cut
    print, '    cut de geo2 : ',lon2_cut, lat2_cut
  ENDIF

;cut des geomat si les limites sont effectivement différentes des limites voulues
  IF ( (limites1[0] NE lon1_cut[0]) OR (limites1[1] NE lon1_cut[1]) OR (limites1[2] NE lat1_cut[0]) OR (limites1[3] NE lat1_cut[1]) ) THEN BEGIN 
    geo1=geocut(geo1, limit=[lon1_cut,lat1_cut])
    print, 'ATTENTION, on coupe la grille 1 ! (1)'
  ENDIF
  IF ( (limites2[0] NE lon2_cut[0]) OR (limites2[1] NE lon2_cut[1]) OR (limites2[2] NE lat2_cut[0]) OR (limites2[3] NE lat2_cut[1]) ) THEN geo2=geocut(geo2, limit=[lon2_cut,lat2_cut])



;-----------------------------------------------------------------
; INTERPOLER GEO2 SUR GRILLE DE GEO1
;-----------------------------------------------------------------


  IF KEYWORD_SET(VERBOSE) THEN BEGIN
    print, '    INTERPOLATING....... '
  ENDIF
; INTERP DU VECTEUR LONGITUDE

;chercher la premiere lon de geo1 comprise dans geo2
  ind_lon1_interp=WHERE( (geo1.lon GE geo2.lon[0]) AND (geo1.lon LE geo2.lon[N_ELEMENTS(geo2.lon)-1]) , cnt)
  ;print, 'lon1_in geo2' , geo1.lon[ind_lon1_interp[0]], geo1.lon[ind_lon1_interp[N_ELEMENTS(ind_lon1_interp)-1]]
  
; convertir cette longitude en nb de delta lon de geo2 x=(lon-lon2min)/delta_lon2
  nb_delta_lon2_init=(geo1.lon[ind_lon1_interp[0]]-geo2.lon[0])/(delta_lon2)

; calculer increment multiple de deltalon2 y=deltalon1/deltalon2
  inc_delta_lon2=delta_lon1/delta_lon2

; creer un vecteur qui commence en x et s'incremente de y, se termine avant la fin de geo2
  vect_interp_delta_lon2=INDGEN(cnt)*inc_delta_lon2
  vect_interp_delta_lon2=vect_interp_delta_lon2+nb_delta_lon2_init

; interpolation de lon2 sur grille lon1
  lon2_interp=INTERPOLATE(geo2.lon, vect_interp_delta_lon2)
  x_fin=N_ELEMENTS(lon2_interp)
  ;print, 'lon2_interp', lon2_interp[0:10]
  ;print, 'lon1', geo1.lon[0:10]
;-----------------------------------------------------

; INTERP DU VECTEUR LATITUDE

;chercher la premiere lat de geo1 comprise dans geo2
  ind_lat1_interp=WHERE( (geo1.lat GE geo2.lat[0]) AND (geo1.lat LE geo2.lat[N_ELEMENTS(geo2.lat)-1]) , cntlat)
  ;print, 'lat1_interp' , geo1.lat[ind_lat1_interp[0]], geo1.lat[ind_lat1_interp[N_ELEMENTS(ind_lat1_interp)-1]]
 
; convertir cette latitude en nb de delta lat de geo2 x=(loat-lat2min)/delta_lat2 
  nb_delta_lat2_init=(geo1.lat[ind_lat1_interp[0]]-geo2.lat[0])/(delta_lat2)
  
; calculer increment multiple de deltalat2 y=deltalat1/deltalat2
  inc_delta_lat2=delta_lat1/delta_lat2
  
; creer un vecteur qui commence en x et s'incremente de y, se termine avant la fin de geo2 
  vect_interp_delta_lat2=INDGEN(cntlat)*inc_delta_lat2
  vect_interp_delta_lat2=vect_interp_delta_lat2+nb_delta_lat2_init

; interpolation de lat2 sur grille lat1
  lat2_interp=INTERPOLATE(geo2.lat, vect_interp_delta_lat2)
  y_fin=N_ELEMENTS(lat2_interp)
  ;print, 'lat2_interp', lat2_interp[0:10]
  ;print, 'lat1', geo1.lat[0:10]
  
  ;------------------------------

; on recoupe les grilles pour supprimer le point de grille en dehors de la zone commune s'il existe -> DEUX GRILLES IDENTIQUES

  minlon=MIN(geo1.lon, /NaN, MAX=maxlon)
  minlat=MIN(geo1.lat, /NaN, MAX=maxlat)
  limites1=[minlon,maxlon,minlat,maxlat]

  IF ( (limites1[0] NE lon2_interp[0]) OR (limites1[1] NE lon2_interp[x_fin-1]) OR (limites1[2] NE lat2_interp[0]) OR (limites1[3] NE lat2_interp[y_fin-1]) ) THEN BEGIN
    geo1=geocut(geo1, limit=[lon2_interp[0],lon2_interp[x_fin-1],lat2_interp[0],lat2_interp[y_fin-1]])
    print, 'ATTENTION, on coupe la grille 1 ! (2)'
  ENDIF


  

  ; creation de la structure geo2_interp et interpolation de geo2 sur la nouvelel grille (la meme que geo1)

  IF ( geotype(geo2) EQ 1) THEN BEGIN  
    geo2_interp=create_geomat(x_fin, y_fin, /TIDE)
    geo2_interp.amp  = INTERPOLATE(geo2.amp, vect_interp_delta_lon2, vect_interp_delta_lat2, /GRID)
    geo2_interp.pha  = INTERPOLATE(geo2.pha, vect_interp_delta_lon2, vect_interp_delta_lat2, /GRID)
    geo2_interp.wave = geo2.wave
    geo2_interp.info = geo2.info
    ;geo2_interp.val  = geo2.val
  ENDIF ELSE BEGIN
    geo2_interp=create_geomat(x_fin, y_fin, s[3] )
    geo2_interp.val  = INTERPOLATE(geo2.val, vect_interp_delta_lon2, vect_interp_delta_lat2,INDGEN(s[3]),  /GRID)
    geo2_interp.info = geo2.info
    geo2_interp.jul  = geo2.jul
  ENDELSE

  geo2_interp.lon  = lon2_interp[*,0]
  geo2_interp.lat  = lat2_interp[*,0]
  
  geo2=geo2_interp
  
    IF KEYWORD_SET(VERBOSE) THEN BEGIN
      print, ' INTERPOLATION COMPLETED !'
    ENDIF

END