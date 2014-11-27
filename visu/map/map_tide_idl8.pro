PRO map_tide_idl8, geo
; test de programme pour tracer une carte de maree a partir des nouveaux outils IDL8.0
; utilisation de la routine IMAGE d'IDL
; To make IDL understand that this image is map data, you must register the image, defining the map boundaries, units, location, and dimensions of the image.



;read limits from the geo structure if nothing else is specified
IF NOT (KEYWORD_SET(limit) OR KEYWORD_SET(zone)) THEN BEGIN
 minlon=MIN(geo.lon, /NAN, MAX=maxlon)
 minlat=MIN(geo.lat, /NAN, MAX=maxlat)  
 limit=[minlon,maxlon,minlat,maxlat]
ENDIF
;on coupe le tableau au nouvelle dimension (ou pas)
  print,"Limite geographique =",limit
  geo = geocut(geo, limit=limit)
;ecriture de limite dans le format de MAP_*
  limit=[limit[2],limit[0]-180.,limit[3],limit[1]]   ; latmin/lonmin/latmax/lonmax  -> pour le map_set
;dimension de l'image en degre
  dim_lon=MAX(geo.lon,/NAN)-MIN(geo.lon,/NAN)
  dim_lat=MAX(geo.lat,/NAN)-MIN(geo.lat,/NAN)
  dim=[dim_lon,dim_lat]
;localisation de l'image
  loc=[MIN(geo.lon,/NAN)-180.,MIN(geo.lat)]
print,"dimension de l'image",dim
print,"localisation de l'image",loc




m=IMAGE(geo.amp,GRID_UNITS='deg',LIMIT=limit,IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,$
         BACKGROUND_COLOR="white",MAP_PROJECTION='Mercator',RGB_TABLE=13)

c=CONTOUR(geo.amp,geo.lon,geo.lat,N_LEVELS=10,GRID_UNITS='deg',C_COLOR="white",/OVERPLOT)
END