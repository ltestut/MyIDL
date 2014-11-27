PRO map_cotidal_chart, geo_in, proj=proj, limit=limit, $
                      f_start=f_start, n_frame=n_frame, scale=scale,  $
                      format=format,$
                      range=range,ncolors=ncolors,c_levels=c_levels,$
                      stream=stream, bathy=bathy,  output=output, _EXTRA=_EXTRA
; programme pour faire une carte cotidale de maree
; a partir d'une matrice geo.lat,geo.lon,geo.amp,geo.pha



;IDL> map_cotidal_chart,geo,LIMIT=[68.5,69.5,-49.0,-48.5],C_LEVELS=[100,120,140,160,180,200,220,240,260],NCOLORS=18,FORMAT='(I2)',RANGE=[0.,24.]

 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='mercator'
IF NOT KEYWORD_SET(scale) THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output='/home/testut/Desktop/idl.png'
IF NOT KEYWORD_SET(ncolors) THEN ncolors=8
IF NOT KEYWORD_SET(format) THEN format='(F5.1)'

 ;gestion de la table de couleur
LOADCT, 0, ncolors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)

 ;creation de la fenetre graphique
xsize = 1000
ysize =  800
w     = window(dimensions=[xsize,ysize])
w.refresh, /disable

 ;determnation du type et des limites de la geomatrice
IF KEYWORD_SET(limit) THEN BEGIN
 geo = geocut(geo_in,limit=limit)
ENDIF ELSE BEGIN
 geo = geo_in
ENDELSE
glimit   = get_geo_lim(geo)
limit    = change2idllimit(glimit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

 ;recuperation des variables a tracer et calcul du zrange et des niveaux
lon = geo.lon
lat = geo.lat
amp = geo.amp*scale
pha = geo.pha

IF NOT KEYWORD_SET(range) THEN range=[MIN(amp,/NAN),MAX(amp,/NAN)]
levels    = range[0]+(range[1]-range[0])/(ncolors)*INDGEN(ncolors)
IF NOT KEYWORD_SET(c_levels) THEN c_levels=levels
print,"Color range = ",range

 ;dimension et localisation de l'image
dim_lon = MAX(lon,/NAN)-MIN(lon,/NAN)  ;dimension de l'image en degre
dim_lat = MAX(lat,/NAN)-MIN(lat,/NAN)
dim     = [dim_lon,dim_lat]
loc     = [MIN(lon,/NAN),MIN(lat)]     ;localisation de l'image


 ;trace le champ scalaire
field   = IMAGE(BYTSCL(amp,MIN=range[0],MAX=range[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,$         
                ZRANGE=[range[0],range[1]],$
                POSITION=[0.05,0.06,0.95,0.80],$
                /CURRENT ,$
                RGB_TABLE=rgb)
                
isofield = CONTOUR(amp,lon,lat,GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=0.,$
                   C_VALUE=levels,C_LABEL_SHOW=1,FONT_SIZE=8,LABEL_FORMAT='(I3)',C_COLOR='white',$
                   C_THICK=0.5)


isoline = CONTOUR(pha,lon,lat,GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=0.,$
                   C_VALUE=c_levels,C_LABEL_SHOW=1,FONT_SIZE=8,LABEL_FORMAT='(I3)',C_COLOR='red',$
                   C_THICK=0.5)


cb = COLORBAR(TARGET=field, /BORDER_ON, $
                POSITION=[0.1, 0.82, 0.9, 0.88],$
                TICKNAME=STRING(levels,FORMAT=format),$
                 TEXTPOS=1,FONT_SIZE=10, $
                 TITLE=geo.wave+' cotidal chart for Kerguelen Island')



coast  = MAPCONTINENTS(FILL_COLOR="antique white",/COASTS,/OVERPLOT,TRANSPARENCY=0,_EXTRA=_EXTRA)

s   = SYMBOL(68.70,-48.90,'circle',/DATA,$
      SYM_SIZE=1.,SYM_THICK=1.,SYM_COLOR='white',$
      SYM_FILLED=1,SYM_FILL_COLOR='orange',$
      SYM_TRANSPARENCY=0);,$
     ; LABEL_STRING='',LABEL_FONT_SIZE=16.,/OVERPLOT)
s.order, /send_to_front

 
s   = SYMBOL(72.05,-50.38,'circle',/DATA,$
      SYM_SIZE=1.,SYM_THICK=1.,SYM_COLOR='white',$
      SYM_FILLED=1,SYM_FILL_COLOR='red',$
      SYM_TRANSPARENCY=0);,$
     ; LABEL_STRING='',LABEL_FONT_SIZE=16.,/OVERPLOT)
s.order, /send_to_front



; ;creation de la projection
;m   = MAP(proj,LIMIT=limit, /CURRENT, $
;          ;GRID_LATITUDE=1,GRID_LONGITUDE=1,$
;          BOX_AXES=1,$
;          title='Title')
;g    = m.MAPGRID

  ;place la legende et un sous-titre
subtitle = text(0.1, 0.01, 'Amplitude in cm (white isocontour) / Phase in degree (red isocontour)', /normal, font_size=8)

   
 ;Make the continental outlines to the top layer of the graphic.
;coast.order, /bring_to_front
   
w.refresh
   
;IF KEYWORD_SET(output) THEN BEGIN
 w.Save, output, RESOLUTION=50.
 w.Save, '/home/testut/Desktop/ker.pdf'
  
 print,output
;ENDIF  
END
