PRO map_cotidal_atlas, atlas_in,  limit=limit, wave=wave, $
                      scale=scale,  $
                      format=format,$
                      amp_range=amp_range,pha_range=pha_range,$
                      ncolors=ncolors,c_levels=c_levels,$
                      proj=proj,$
                      stream=stream, bathy=bathy,  output=output, _EXTRA=_EXTRA


 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj)   THEN proj='mercator'
IF NOT KEYWORD_SET(scale)  THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output='/home/testut/Desktop/idl.png'
IF NOT KEYWORD_SET(ncolors)THEN ncolors=10
IF NOT KEYWORD_SET(format) THEN format='(F5.1)'
IF NOT KEYWORD_SET(wave)   THEN wave='M2'

 ;determnation du type et des limites de la geomatrice
IF KEYWORD_SET(limit) THEN BEGIN
 atlas = tatlas_cut(atlas_in,limit=limit)
ENDIF ELSE BEGIN
 atlas = atlas_in
ENDELSE
glimit   = get_geo_lim(atlas)
limit    = change2idllimit(glimit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

 ;gestion de la table de couleur
LOADCT, 0, ncolors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)

 ;creation de la fenetre graphique
xsize = 1000
ysize =  800
w     = window(dimensions=[xsize,ysize])
w.refresh, /disable


 ;recuperation des variables a tracer et calcul du zrange et des niveaux
lon = atlas.lon
lat = atlas.lat

 ;dimension et localisation de l'image
dim_lon = MAX(lon,/NAN)-MIN(lon,/NAN)  ;dimension de l'image en degre
dim_lat = MAX(lat,/NAN)-MIN(lat,/NAN)
dim     = [dim_lon,dim_lat]
loc     = [MIN(lon,/NAN),MIN(lat)]     ;localisation de l'image

idw = WHERE(atlas.wave.name EQ wave, cpt)
IF (cpt LT 1) THEN STOP,'No '+wave+' wave in this taltas'
amp = atlas.wave[idw].amp*scale
pha = atlas.wave[idw].pha

IF NOT KEYWORD_SET(amp_range) THEN amp_range=[MIN(amp,/NAN),MAX(amp,/NAN)]
IF NOT KEYWORD_SET(pha_range) THEN pha_range=[MIN(pha,/NAN),MAX(pha,/NAN)]
amp_levels    = amp_range[0]+(amp_range[1]-amp_range[0])/(ncolors)*INDGEN(ncolors)
pha_levels    = pha_range[0]+(pha_range[1]-pha_range[0])/(ncolors)*INDGEN(ncolors)

;IF NOT KEYWORD_SET(amp_levels) THEN amp_levels=levels
print,"Apmlitude range = ",amp_range
print,"Phase     range = ",pha_range


 ;trace le champ scalaire
field   = IMAGE(BYTSCL(amp,MIN=amp_range[0],MAX=amp_range[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,$         
                ZRANGE=[amp_range[0],amp_range[1]],$
                POSITION=[0.05,0.06,0.95,0.80],$
                TITLE=atlas.info,$
                /CURRENT ,$
                RGB_TABLE=rgb)
                
isofield = CONTOUR(amp,lon,lat,GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=0.,$
                   C_VALUE=amp_levels,C_LABEL_SHOW=1,FONT_SIZE=8,LABEL_FORMAT='(I3)',C_COLOR='white',$
                   C_THICK=0.5)

isoline = CONTOUR(pha,lon,lat,GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=0.,$
                   C_VALUE=pha_levels,C_LABEL_SHOW=1,FONT_SIZE=8,LABEL_FORMAT='(I3)',C_COLOR='red',$
                   C_THICK=0.5)


cb = COLORBAR(TARGET=field, /BORDER_ON, $
                POSITION=[0.05, 0.82, 0.95, 0.88],$
                TICKNAME=STRING(amp_levels,FORMAT=format),$
                 TEXTPOS=1,FONT_SIZE=10, $
                 TITLE=atlas.wave[0].name+' cotidal chart')



coast  = MAPCONTINENTS(FILL_COLOR="antique white",/COUNTRIES,TRANSPARENCY=0,_EXTRA=_EXTRA)


;s   = SYMBOL(72.05,-50.38,'circle',/DATA,$
;      SYM_SIZE=1.,SYM_THICK=1.,SYM_COLOR='white',$
;      SYM_FILLED=1,SYM_FILL_COLOR='red',$
;      SYM_TRANSPARENCY=0);,$
;     ; LABEL_STRING='',LABEL_FONT_SIZE=16.,/OVERPLOT)
;s.order, /send_to_front




  ;place la legende et un sous-titre
subtitle = text(0.1, 0.01, 'Amplitude in cm (white isocontour) / Phase in degree (red isocontour)', /normal, font_size=8)

   
 ;Make the continental outlines to the top layer of the graphic.
;coast.order, /bring_to_front
   
w.refresh
   
;IF KEYWORD_SET(output) THEN BEGIN
 w.Save, output, RESOLUTION=50.
 w.Save, '/home/testut/Desktop/atlas.pdf'
  
 print,output
;ENDIF  
END
