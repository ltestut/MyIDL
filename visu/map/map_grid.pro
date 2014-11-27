PRO map_grid, geo, proj=proj, verbose=verbose
; programme pour tracer les points de grille d'une geomtrice ainsi que la position 
; d'un maregraphe et de son point de grille le plus proche


 ;gestion des mot-clefs
IF NOT KEYWORD_SET(proj) THEN proj='stereographic'

 ;dimensions initiales de la bathy
nx     = N_ELEMENTS(geo.lon)
ny     = N_ELEMENTS(geo.lat)
minlon = MIN(geo.lon, /NAN, MAX=maxlon)
minlat = MIN(geo.lat, /NAN, MAX=maxlat)
limit  = [minlat,minlon,maxlat,maxlon] ;ecriture de limite dans le format de MAP_* : latmin/lonmin/latmax/lonmax
 ;determination des pas en longitude et latitude
dlon   = (maxlon-minlon)/(nx-1)
dlat   = (maxlat-minlat)/(ny-1)

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'DIMENSION DE LA BATHY ORIGINALE :'
 PRINT,'------------------------------- :' 
 PRINT,'taille de la matrice (nx/ny)    :',nx,'/',ny
 PRINT,'lonmin/lonmax/latmin/latmax     :',minlon,'/',maxlon,'/',minlat,'/',maxlat
 PRINT,'dlon/dlat                       :',dlon,'/',dlat
ENDIF


m   = MAP(proj,LIMIT=limit, COLOR='light blue')
c   = MAPCONTINENTS(FILL_COLOR='beige')
g   = m.mapgrid
g.LABEL_SHOW     = 1
g.BOX_AXES       = 1
g.BOX_ANTIALIAS  = 1

;g.GRID_LATITUDE  = dlat
;g.GRID_LONGITUDE = dlon
;m.mapgrid.order, /send_to_back


; bcp trop long !!!
;FOR i=10,20 DO BEGIN
;FOR j=0,ny DO BEGIN
;s = symbol(geo.lon[i],geo.lat[j], 'star', /sym_filled,  sym_fill_color='yellow', /data)
;
;
;ENDFOR
;ENDFOR

END