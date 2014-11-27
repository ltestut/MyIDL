FUNCTION geomat2val, geo, lon=lon, lat=lat, amp=amp, pha=pha, verbose=verbose
; renvoie la valeur interpolee aux points de coordonnees (lon,lat)
; après une interpolation bilineaire (/amp et /pha pour les geomat de maree)
; pour les pts proches de la cote il faut mieux utiliser geomat2nearestpoint

 ;gestion des mots-clefs et initialisation
IF NOT KEYWORD_SET(lon) THEN STOP,'Need lon and lat keyword'
IF N_ELEMENTS(lon) NE N_ELEMENTS(lat) THEN STOP,'lon et lat must have same dimension'
npts = N_ELEMENTS(lon)
val  = FLTARR(npts)

 ;on selectionne les pts valides de la geomatrice et on recupere
 ;le geotype de la matrice
gtype  = geovalid(geo, VLON=ilon, VLAT=ilat)
nvalid = N_ELEMENTS(ilon)

 ;on selectione le champ 2D
CASE (gtype) OF
  0 : BEGIN
      H = geo.val
  END
  1 : BEGIN
      IF KEYWORD_SET(amp) THEN H = geo.amp
      IF KEYWORD_SET(pha) THEN H = geo.pha
      IF NOT KEYWORD_SET(amp) AND NOT KEYWORD_SET(pha) THEN STOP,'Need /amp or /pha keyword'
  END
ENDCASE

FOR i=0,npts-1 DO BEGIN ;on parcours toutes les coordonnees (lon,lat) a interpoler
  val[i]=BILINEAR(H,igeo(geo.lon,lon[i]),igeo(geo.lat,lat[i]),MISSING=!VALUES.F_NAN) ;on fait d'abord une interpolation bilineaire
  IF (KEYWORD_SET(verbose) AND FINITE(val[i])) THEN BEGIN
   PRINT,FORMAT="('Position du point recherche           : ',2F8.2)",lon[i],lat[i]
   PRINT,FORMAT="('Interpolation bilineaire              : ')"      
   PRINT,FORMAT="('Valeur interpolee                     : ',F8.2)  ",val[i]
;   map_geogrid,geo,LON=lon[i],LAT=lat[i],/VERBOSE
  ENDIF
  IF (FINITE(val[i]) EQ 0) THEN  BEGIN ;si elle ne fonctionne pas on choisit le pt le plus proche
      d = FLTARR(nvalid)   ;tableau des distances
      ;calul de la distande ou point (lon,lat)
      FOR j=0,nvalid-1 DO d[j]  = MAP_2POINTS(lon[i], lat[i], geo.lon[ilon[j]], geo.lat[ilat[j]] ,/METERS)  ;on enleve les valeur dupliquees
      id_near = WHERE(d EQ MIN(d,/NAN),cpt_near)
      id_lon  = ilon[id_near]
      id_lat  = ilat[id_near]
      val[i]  = H[ilon[id_near],ilat[id_near]]      
      IF KEYWORD_SET(verbose) THEN BEGIN
       PRINT,FORMAT="('Position du point recherche           : ',2F8.2)",lon[i],lat[i]
       PRINT,FORMAT="('Recherche du point le plus proche     : ')"      
       PRINT,FORMAT="('Position du point le plus proche [Km] : ',3F8.2)",geo.lon[ilon[id_near]],geo.lat[ilat[id_near]],d[id_near]/1000.
       PRINT,FORMAT="('Indice du point le plus proche        : ',2I8)  ",id_lon,id_lat
       PRINT,FORMAT="('Valeur interpolee                     : ',F8.2)  ",val[i]
 ;      map_geogrid,geo,LON=lon[i],LAT=lat[i],NEAREST=[ilon[id_near],ilat[id_near]]
     ENDIF
  ENDIF
ENDFOR 
RETURN,val
END