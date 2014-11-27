PRO nmap_geomat, geo_in, limit=limit, proj=proj, nlev=nlev, range=range, _EXTRA=_EXTRA
; prog qui va tracer une geomatrice


 ;gestion des mots-clefs 
IF KEYWORD_SET(limit) THEN BEGIN
 geo = geocut(geo_in,limit=limit)
ENDIF ELSE BEGIN
 geo = geo_in
ENDELSE
IF NOT KEYWORD_SET(proj) THEN proj='geographic'
IF NOT KEYWORD_SET(nlev) THEN nlev=10


 ;determnation du type et des limites de la geomatrice
glimit   = get_geo_lim(geo)
limit    = change2idllimit(glimit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 
field    = geomat2field(geo,_EXTRA=_EXTRA)
minfield = MIN(field,/NAN,MAX=maxfield)
IF NOT KEYWORD_SET(range) THEN range=[minfield,maxfield] 
level    = INDGEN(nlev)*((range[1]-range[0])/nlev)+range[0]


map      = MAP(proj,LIMIT=limit)
;grid  = MAP.MAPGRID
;coast = MAPCONTINENTS(color='black')

cont  = CONTOUR(field,geo.lon,geo.lat,GRID_UNITS='deg',$
                 N_LEVELS=nlev, RGB_INDICES=BYTSCL(level), RGB_TABLE=13, C_VALUE=level, $
                 /OVERPLOT,/FILL)
cbar =  COLORBAR(target=cont, $
      orientation=0, $
      textpos=1, $
      font_size=10, $
      tickdir=1, $      
      position=[0.1, 0.88, 0.9, 0.9], $
      title='Height (m)')
 
END