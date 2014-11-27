PRO map_geogrid, geo_in, geo2, lon=lon, lat=lat, info=info, nearest=nearest, around=around, limit=limit, fscale=fscale, verbose=verbose
; programme pour tracer les points de grille d'une geomtrice autour de la position 
; d'un maregraphe et de son point de grille le plus proche

 ;gestion des mots-clefs
IF NOT KEYWORD_SET(fscale) THEN fscale=3.
footprint = ((1./111.)*fscale)
 ;position du point le plus proche
IF KEYWORD_SET(nearest) THEN BEGIN
 near_lon = geo_in.lon[nearest[0]]
 near_lat = geo_in.lat[nearest[1]]
ENDIF
 ;position des pts autour
IF KEYWORD_SET(around) THEN BEGIN
 around_lon = geo_in.lon[around[0,*]]
 around_lat = geo_in.lat[around[1,*]]
ENDIF

 ;dimensions initiales de la geomatrice
nx     = N_ELEMENTS(geo_in.lon)
ny     = N_ELEMENTS(geo_in.lat)
minlon = MIN(geo_in.lon, /NAN, MAX=maxlon)
minlat = MIN(geo_in.lat, /NAN, MAX=maxlat)


 ;determination des pas en longitude et latitude
dlon   = (maxlon-minlon)/(nx-1)
dlat   = (maxlat-minlat)/(ny-1)
dl     = 0.5 ;on ajoute x-deg de chaque cote du pt de ref
 ;on decoupe la matrice autour du point de reference
IF NOT KEYWORD_SET(limit) THEN limit=[lon-dl,lon+dl,lat-dl,lat+dl]
geo    = geo_cut(geo_in,LIMIT=limit,/QUIET)
limit  = change2idllimit(limit)

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'DIMENSION DE LA MATRICE         :'
 PRINT,'------------------------------- :' 
 PRINT,'taille de la matrice (nx/ny)    :',nx,'/',ny
 PRINT,'lonmin/lonmax/latmin/latmax     :',minlon,'/',maxlon,'/',minlat,'/',maxlat
 PRINT,'dlon/dlat                       :',dlon,'/',dlat
 PRINT,'POSITION DU POINT DE REF        :'
 PRINT,'------------------------------- :' 
 PRINT,'lon/lat                         :',lon,'/',lat
 IF KEYWORD_SET(nearest) THEN PRINT,'lon/lat nearest point           :',near_lon,'/',near_lat
 PRINT,'zone de tracage                 :',limit[1],'/',limit[3],'/',limit[0],'/',limit[2]
ENDIF

 ;get definit value of grid
geo_valid,geo, VLON=ilon, VLAT=ilat

MAP_SET, /MERCATOR, /ISOTROPIC, LIMIT=limit,GRID=0,_EXTRA=_EXTRA ;, /NOERASE
PLOTS,geo.lon[ilon], geo.lat[ilat], psym=1, /DATA, COLOR=cgcolor("red",253), _EXTRA=_EXTRA
tvcircle, footprint, lon, lat, /FILL, /DATA, COLOR=cgcolor('yellow',252) ;, /LINE_FILL, SPACING=0.05, ORIENTATION=45.
;tvcircle, footprint/2, near_lon, near_lat, /FILL, /DATA, COLOR=cgcolor('rose',251), /LINE_FILL, SPACING=0.05, ORIENTATION=-45.
IF KEYWORD_SET(around) THEN PLOTS,around_lon, around_lat, psym=6, thick=2, /DATA, COLOR=cgcolor("blue",251), _EXTRA=_EXTRA
IF KEYWORD_SET(nearest) THEN PLOTS,near_lon, near_lat, psym=6, thick=3, /DATA, COLOR=cgcolor("red",250), _EXTRA=_EXTRA
IF KEYWORD_SET(info) THEN XYOUTS, lon, lat, info, CHARSIZE=6,  /DATA, COLOR=cgcolor("yellow",252), _EXTRA=_EXTRA
IF (N_PARAMS() EQ 2) THEN PLOTS,geo2.lon[ilon], geo2.lat[ilat], psym=1, /DATA, COLOR=cgcolor("yellow",249), _EXTRA=_EXTRA



MAP_CONTINENTS, /COASTS, /OVERPLOT, /HIRES, FILL_CONTINENTS=2, LIMIT=limit, COLOR=cgcolor("grey",249), ORIENTATION=45
MAP_GRID,/BOX_AXES,LABEL=2

END