FUNCTION geomat2nearestpoint, geo, lat=lat,lon=lon, amp=amp, pha=pha, verbose=verbose,id_lon=id_lon,id_lat=id_lat
; renvoie les indices du point (i,j) valid de la matrice les plus proches de (lon,lat)
; ainsi que la valeur ou un tableau si la matrice a une dimension temporelle

nt = 0 ;on initialise le pas de temps a zero (par defaut pour les matrices non-temporelles)
IF NOT (KEYWORD_SET(amp) OR KEYWORD_SET(pha)) THEN BEGIN
 s   = SIZE(geo.val)
 IF (s[0] EQ 3) THEN BEGIN
  nt  = s[3]             ;nbre de pas de temps
  H   = geo.val[*,*,1]   ;on extrait un seul pas de temps
 ENDIF ELSE BEGIN
  H   = geo.val
 ENDELSE
ENDIF
IF KEYWORD_SET(amp) THEN BEGIN
 H   = geo.amp
ENDIF
IF KEYWORD_SET(pha) THEN BEGIN 
 H   = geo.pha  
ENDIF

s      = SIZE(H)
ncol   = s[1]
nrow   = s[2]
index  = WHERE(FINITE(H),/L64,nvalid) ;indice des valeurs definies de la matrice
ilon   = index MOD ncol                ;indice des longitudes definies
ilat   = index/ncol                    ;indice des latitudes definies
d      = FLTARR(nvalid)               ;tableau des distances

 ;calul de la distande ou point (lon,lat)
FOR I=0,nvalid-1 DO d[i]  = MAP_2POINTS(lon, lat, geo.lon[ilon[i]], geo.lat[ilat[i]] ,/METERS)  ;on enleve les valeur dupliquees
id_near = WHERE(d EQ MIN(d,/NAN),cpt_near)
id_lon  = ilon[id_near]
id_lat  = ilat[id_near]
IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,FORMAT="('Position du point recherche           : ',2F8.2)",lon,lat
  PRINT,FORMAT="('Position du point le plus proche [Km] : ',3F8.2)",geo.lon[ilon[id_near]],geo.lat[ilat[id_near]],d[id_near]/1000.
  PRINT,FORMAT="('Indice du point le plus proche        : ',2I8)  ",id_lon,id_lat
  ;PRINT,FORMAT="('Matrice temporelle [nt] ou pas [0]    : ',I5)   ",nt
  map_geogrid,geo,LON=lon,LAT=lat,NEAREST=[ilon[id_near],ilat[id_near]]
ENDIF

IF (nt GT 0) THEN BEGIN
  out = FLTARR(ncol,nrow,nt)
  out = geo.val[ilon[id_near],ilat[id_near],*]
 RETURN,out
ENDIF ELSE BEGIN
 RETURN,H[ilon[id_near],ilat[id_near]]
ENDELSE
END