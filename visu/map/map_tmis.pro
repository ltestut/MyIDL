FUNCTION map_tmis, tmis_in, limit=limit, zone=zone, proj=proj, scale=scale, $
                    range=range, ncolors=ncolors, title=title, symsize=simsize, $
                    label=label ,$
                    output=output, wave=wave,$
                    _EXTRA=_EXTRA
; display on a map the misfits for a given wave
; wave  = 'M2'  ==> affiche a cote du nom de la station l'amplitude et la phase de l'onde
; 

IF NOT KEYWORD_SET(title) THEN title='MISFITS'
IF NOT KEYWORD_SET(wave) THEN wave='M2'

tmis   = where_tmis(tmis_in,WAVE=wave)


IF NOT KEYWORD_SET(limit) THEN BEGIN
 limit = get_tmis_limit(tmis)
 dl    = 1. ;on ajout 2deg de chaque cote des limites
 limit = [limit[0]-dl,limit[1]+dl,limit[2]-dl,limit[3]+dl]
ENDIF
tmis     = cut_tmis(tmis,LIMIT=limit) 
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin]

IF NOT KEYWORD_SET(proj) THEN proj='mercator'
IF NOT KEYWORD_SET(ncolors) THEN ncolors=16
IF NOT KEYWORD_SET(symsize) THEN symsize=1.
IF NOT KEYWORD_SET(scale) THEN   scale= 1.

 ;creation de la fenetre graphique
xsize = 1800
ysize = 1400
w     = window(dimensions=[xsize,ysize])
w.refresh, /disable
LOADCT, 41, NColors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)
TVLCT, rgb

amplitude = tmis.sta.wave.da*scale 
phase     = tmis.sta.wave.dp
value     = amplitude
IF NOT KEYWORD_SET(range) THEN range  =[MIN(value,/NAN),MAX(value,/NAN)]
label     = STRCOMPRESS(tmis.sta.name);+$
;            STRCOMPRESS(STRING(value,FORMAT='(F8.2)'))+'/'$
;           +STRCOMPRESS(STRING(phase,FORMAT='(F8.2)'))
       irange=FLOOR((value - range[0])/(ABS(range[1]-range[0])/255.))
       symco=(transpose(rgb))[*,irange]

m   = MAP(proj,LIMIT=limit,FILL_COLOR='white',$  
         OVERPLOT=ovp,TRANSPARENCY=0,LABEL_SHOW=0,/BOX_AXES,$
         TITLE=title)
g   = MAPGRID(GRID_LONGITUDE = 10.,GRID_LATITUDE = 10., LINESTYLE='dash',COLOR='grey')
c   = MAPCONTINENTS(FILL_COLOR="antique white",/COUNTRIES)


s   = SYMBOL(tmis.sta.lon,tmis.sta.lat,'circle',/DATA,$
      TARGET=m,$
      SYM_SIZE=2.0,SYM_THICK=2,SYM_COLOR=symco,$
      SYM_FILLED=1,SYM_FILL_COLOR=symco,$
      LABEL_STRING=label,LABEL_FONT_SIZE=0.5,LABEL_COLOR='black',LABEL_ORIENTATION=0.,$
      LABEL_POSITION='C',LABEL_FILL_BACKGROUND=0,LABEL_TRANSPARENCY=0,$
      /OVERPLOT)
      
      
xcoord = DBLARR(2,N_ELEMENTS(tmis.sta.lon))
ycoord = DBLARR(2,N_ELEMENTS(tmis.sta.lon))


;arr_length  = ABS(tmis.sta.wave.da)
arr_length  = 1.
arr_sign    = SIGN(tmis.sta.wave.dp)
id_plus     = WHERE(arr_sign EQ 1.,COMPLEMENT=id_minus)
arr_color   = MAKE_ARRAY(N_ELEMENTS(arr_sign),/STRING,VALUE='blue')
arr_color[id_plus] = 'red' 
xcoord[0,*] = tmis.sta.lon
xcoord[1,*] = tmis.sta.lon+arr_length*COS(rad(tmis.sta.wave.dp))
ycoord[0,*] = tmis.sta.lat
ycoord[1,*] = tmis.sta.lat+arr_length*SIN(rad(tmis.sta.wave.dp))

help,xcoord,ycoord
arr    = ARROW(xcoord, ycoord,/DATA, TARGET=m,$
               HEAD_INDENT=0.5,HEAD_ANGLE=45.,HEAD_SIZE=0.1,$
               COLOR=arr_color,$
               /CLIP)
            
levels    = range[0]+(range[1]-range[0])/(ncolors-1)*INDGEN(ncolors)
scaledData = BytScl(DIST(10,10), /NAN, TOP=(NColors-1), MIN=range[0], MAX=range[1])
fakeImage = Image(scaledData, RGB_Table=rgb, /Current, /Hide)
;cb = COLORBAR(TARGET=fakeImage)
cb = Colorbar(Target=fakeImage,ORIENTATION=1,POSITION=[0.1,0.1,0.12,0.9],$
                 RGB_TABLE=rgb, /BORDER, TAPER=2, $
                 TICKNAME=STRING(levels,FORMAT='(F6.1)'))

;m.save,'mgr.kml'
;m.order, /SEND_TO_BACK
g.Order, /SEND_TO_BACK
;s.Order, /BRING_TO_FRONT
;c.order, /SEND_BACKWARD
;arr.Order, /BRING_TO_FRONT
w.refresh
IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=150
ENDIF
RETURN, w
END