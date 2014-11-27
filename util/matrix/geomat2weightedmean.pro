FUNCTION geomat2weightedmean, geo, lat=lat,lon=lon, amp=amp, pha=pha, scale=scale, verbose=verbose
; renvoie la valeur moyenne (ponderer par la distance) d'un point (lon,lat)
; tableau si la matrice a une dimension temporelle

 ;gestion des mots-clefs
IF NOT KEYWORD_SET(scale) THEN scale=1.2 ;definie le rayon de recherche des pts le + proches scale*la valeur la plus proche

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
 ;on reduit la matrice a ses valeurs finies
s      = SIZE(H)
ncol   = s[1]
nrow   = s[2]
index  = WHERE(FINITE(H),/L64,nvalid) ;indice des valeurs definies de la matrice
ilon   = index MOD ncol                ;indice des longitudes definies
ilat   = index/ncol                    ;indice des latitudes definies
d      = FLTARR(nvalid)               ;tableau des distances

 ;calul de la distande ou point (lon,lat)
FOR I=0,nvalid-1 DO d[i]  = MAP_2POINTS(lon, lat, geo.lon[ilon[i]], geo.lat[ilat[i]] ,/METERS)  ;on enleve les valeur dupliquees
min_dst         = MIN(d,/NAN)
id_near         = WHERE(d EQ min_dst,cpt_near)
id_around       = WHERE(d LE min_dst*scale,cpt_around)
som_dst         = TOTAL(d[id_around],/NAN)
tab_around      = FLTARR(2,cpt_around)
tab_around[0,*] = ilon[id_around]
tab_around[1,*] = ilat[id_around]

IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,FORMAT="('Position du point recherche           : ',2F8.2)",lon,lat
  PRINT,FORMAT="('Position du point le plus proche [Km] : ',3F8.2)",geo.lon[ilon[id_near]],geo.lat[ilat[id_near]],d[id_near]/1000.
  PRINT,FORMAT="('Indice du point le plus proche        : ',2I8)  ",ilon[id_near],ilat[id_near]
  PRINT,FORMAT="('Nombre de point dans le rayon         : ',I3,' [R=',F8.2,'Km]')  ",cpt_around,min_dst*scale/1000.
  ;PRINT,FORMAT="('Matrice temporelle [nt] ou pas [0]    : ',I5)   ",nt
  map_geogrid,geo,LON=lon,LAT=lat,NEAREST=[ilon[id_near],ilat[id_near]],AROUND=tab_around,/VERBOSE
ENDIF

IF (nt GT 0) THEN BEGIN
  out = FLTARR(ncol,nrow,nt)
  out = geo.val[ilon[id_near],ilat[id_near],*]
 RETURN,out
ENDIF ELSE BEGIN
 val_tot=0 ;initialisation du total
 FOR j=0,cpt_around-1 DO val_tot+=(d[id_around[j]]/som_dst)*H[ilon[id_around[j]],ilat[id_around[j]]]
 RETURN,val_tot
ENDELSE

END