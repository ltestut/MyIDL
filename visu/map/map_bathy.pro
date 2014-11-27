PRO map_bathy, geo_in, limit=limit, fast=fast, smooth=smooth, zvalue=zvalue, verbose=verbose
; programme pour tracer une carte de bathy a partir des nouveaux outils IDL8.x
; utilisation de la routine IMAGE d'IDL
; To make IDL understand that this image is map data, you must register the image, defining the map boundaries, units, location, and dimensions of the image.

 ;dimensions initiales de la bathy
nx     = N_ELEMENTS(geo_in.lon)
ny     = N_ELEMENTS(geo_in.lat)
minlon = MIN(geo_in.lon, /NAN, MAX=maxlon)
minlat = MIN(geo_in.lat, /NAN, MAX=maxlat)
zmin   = MIN(geo_in.val,MAX=zmax)  
IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'DIMENSION DE LA BATHY ORIGINALE :'
 PRINT,'------------------------------- :' 
 PRINT,'taille de la matrice (nx/ny)    :',nx,'/',ny
 PRINT,'lonmin/lonmax/latmin/latmax     :',minlon,'/',maxlon,'/',minlat,'/',maxlat
 PRINT,'zmin/zmax/zrange                :',zmin,'/',zmax,'/',ABS(zmax-zmin)
 PRINT,'dlon/dlat                       :',ABS((maxlon-minlon)/FLOAT(nx)),'/',ABS((maxlat-minlat)/FLOAT(ny))
 ENDIF
 ;on divise les dimenstions par 10 pour un tracage rapide
IF KEYWORD_SET(fast) THEN BEGIN
  nx      = FLOOR(N_ELEMENTS(geo_in.lon)/10)
  ny      = FLOOR(N_ELEMENTS(geo_in.lat)/10)
  geo     = create_geomat(nx,ny,/TWOD)
  geo.val = CONGRID(geo_in.val,nx,ny)
  geo.lon = CONGRID(geo_in.lon,nx)
  geo.lat = CONGRID(geo_in.lat,ny)
ENDIF ELSE BEGIN
  geo     = geo_in
ENDELSE
 ;on lisse la bathy
IF KEYWORD_SET(smooth) THEN BEGIN
  geo.val=SMOOTH(geo.val,3,/NAN)
ENDIF
;##############################################################


 ;lecture des limites geographiques de la zone
IF NOT (KEYWORD_SET(limit) OR KEYWORD_SET(zone)) THEN BEGIN
 minlon=MIN(geo.lon, /NAN, MAX=maxlon)
 minlat=MIN(geo.lat, /NAN, MAX=maxlat)  
 limit=[minlon,maxlon,minlat,maxlat]
ENDIF
 ;on coupe au nouvelle dimension (ou pas)
  geo   = geocut(geo, limit=limit)
;ecriture de limite dans le format de MAP_*
  limit = [limit[2],limit[0],limit[3],limit[1]]   ; latmin/lonmin/latmax/lonmax  -> pour le map_set

IF NOT (KEYWORD_SET(zvalue)) THEN BEGIN
 ineg = WHERE(geo.val LE 0) ;on selectionne la partie <0 de la bathy
 zmin = MIN(geo.val[ineg],MAX=zmax) 
 zrange = ABS(zmax-zmin)
 print,"Zmin/zmax/range               :",zmin,'/',zmax,'/',zrange
 zvalue=[-500,-1000,-2000,-3000,-4000]
ENDIF

;dimension de l'image en degre
  dim_lon=MAX(geo.lon,/NAN)-MIN(geo.lon,/NAN)
  dim_lat=MAX(geo.lat,/NAN)-MIN(geo.lat,/NAN)
  dim=[dim_lon,dim_lat]
;localisation de l'image
  loc=[MIN(geo.lon,/NAN),MIN(geo.lat)]
print,"dimension de l'image en degree  :",dim
print,"localisation de l'image         :",loc


map = MAP('geographic',LIMIT=limit)
img = IMAGE(geo.val,geo.lon,geo.lat,GRID_UNITS='deg',LIMIT=limit,IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,$
             /OVERPLOT,RGB_TABLE=13)
c   = CONTOUR(geo.val,geo.lon,geo.lat,C_VALUE=zvalue,C_COLOR="white",GRID_UNITS='deg',$
            /OVERPLOT)
m   = MAPCONTINENTS(FILL_COLOR='beige',/COUNTRIES)
cbar =  COLORBAR(target=img, $
      orientation=1, $
      textpos=1, $
      font_size=10, $
      tickdir=1, $
      position=[0.86, 0.30, 0.88, 0.70], $
      title='Height (m)')
END