PRO simple_map, limit=limit, zone=zone, proj=proj, _EXTRA=_EXTRA
; permet de tracer un fond de carte

;determination des limites geographiques de la carte
IF KEYWORD_SET(zone) THEN BEGIN
 limit=use_zone(zone=zone)
 limit=[limit[1],limit[3],limit[0],limit[2]]
ENDIF
IF NOT (KEYWORD_SET(limit) OR KEYWORD_SET(zone)) THEN BEGIN
 minlon=-180.   & maxlon=180.
 minlat=-90. & maxlat=90.  
 limit=[minlon,maxlon,minlat,maxlat]
ENDIF
;ecriture de limite dans le format de MAP_*
 PRINT,"Limit geo : ",limit
 limit=[limit[2],limit[0],limit[3],limit[1]]   ; latmin/lonmin/latmax/lonmax  -> pour le map_set

;determination de la projection
IF NOT KEYWORD_SET(proj) THEN proj='Mollweide'

m     = MAP(proj,LIMIT=limit,CENTER_LONGITUDE=00,fill_color='white')
grid  = m.MAPGRID
cont  = MAPCONTINENTS(FILL_COLOR="antique white",_EXTRA=_EXTRA)
grid.FONT_SIZE=12




m.title='ROSAME/NIVMER'
gloss=load_gloss(/LOCATION)
s=symbol(gloss.lon,gloss.lat,'o',/DATA,/OVERPLOT,SYM_FILL_COLOR='black',$
         SYM_FILLED=1,SYM_COLOR='black',SYM_SIZE=0.8)
s2=symbol([77.53119659,70.21900177,140.00199890,51.86999893],$
          [-38.71469879,-49.35219955,-66.66510010,-46.41999817],'o',$
          LABEL_STRING=['St-Paul','Kerguelen',"Dumont d'Urville",'Crozet'],$
          LABEL_FONT_SIZE=6,$
          SYM_SIZE=1,SYM_FILL_COLOR='red',SYM_FILLED=1,SYM_COLOR='black',$
          /DATA,/OVERPLOT)   
         
PRINT,'toto'
END