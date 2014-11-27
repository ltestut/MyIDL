PRO map_geofield, geo_in, limit=limit, range=range, ncolors=ncolors, im=im, kml=kml, _EXTRA=_EXTRA
; map a geo field with Object Graphic routine
;  limit=[10,20,-50,50]    : select geographical limit
;  range=[-10.,10.]        : select the zrange value
;  ncolors=10              : select the number of color (default is 10)
;  /IM                     : to map an image instead of a contour
;  /KML                    : write a kml file in !kml
; _EXTRA keyword
;  scale=100.   : to change the scale of the field
; frame = 
; tdate = "010119991200"

 ;test the High Resolution keyword
IF N_ELEMENTS(_EXTRA) THEN id  = WHERE(TAG_NAMES(_EXTRA) EQ 'HIRES',hires) ELSE hires=0

 ;cut/determine the limit of geomatrix and put in IDL format
IF KEYWORD_SET(limit) THEN geo = geocut(geo_in,limit=limit) ELSE geo=geo_in
limit    = change2idllimit(get_geo_lim(geo,/QUIET))                           

 ;extract the lon,lat and field values
field    = geo2field(geo,lon,lat,full_range,tstamp,_EXTRA=_EXTRA)


print,full_range
; ;compute the range and color scale
 format ='(F'+STRCOMPRESS(MAX(STRLEN(STRCOMPRESS(full_range,/REMOVE_ALL))),/REMOVE_ALL)+'.2)'
IF NOT KEYWORD_SET(ncolors) THEN ncolors   = 10
IF NOT KEYWORD_SET(range) THEN range=full_range
IF KEYWORD_SET(step) THEN step = (range[1]-range[0])/step ELSE step = ncolors
levels    = range[0]+(range[1]-range[0])/(step)*INDGEN(step)
ctable    = COLORTABLE([[0,0,255],[255,255,255],[255,0,0]],NCOLORS = ncolors)
ctable    = COLORTABLE([[255,255,255],[255,0,0]],NCOLORS = ncolors)


PRINT,FORMAT='("map range / ncolors :",F6.1,"<-->",F-6.1,"  /  ",I2)',range,ncolors
print,levels
;PRINT,"map range / ncolors :",range,ncolors


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
pos      = [0.2,0.2,0.8,0.8]
proj     = 'mercator'
map      = MAP(proj,LIMIT=limit,POSITION=pos,/CURRENT)
cst      = MAPCONTINENTS(FILL_COLOR='antique white',/HIDE,HIRES=hires)

IF KEYWORD_SET(im) THEN BEGIN
 cst.hide=0
 cst.Order,/BRING_FORWARD
 mfield    = IMAGE(BYTSCL(field,MIN=range[0],MAX=range[1],/NAN),/CURRENT,$
                MAP_PROJECTION=proj,limit=limit,POSITION=pos,$
                IMAGE_LOCATION=[MIN(lon),MIN(lat)],IMAGE_DIMENSIONS=[(lon[-1]-lon[0]),(lat[-1]-lat[0])],GRID_UNITS=2,$
                RGB_TABLE=CONGRID(ctable, 256, 3))
ENDIF ELSE BEGIN  
 IF KEYWORD_SET(kml) THEN BEGIN 
   kml_cnt = CONTOUR(field, lon, lat, GRID_UNITS='deg', C_VALUE=levels, RGB_TABLE=39, /OVERPLOT, C_THICK=[2])
   map.save, !kml
 ENDIF
 mfield = CONTOUR(field, lon, lat, GRID_UNITS='deg', C_VALUE=levels, RGB_TABLE=39, /OVERPLOT, C_THICK=[2], C_LABEL_SHOW=0)
ENDELSE

cbar =  COLORBAR(target=mfield, TICKNAME=STRING(levels,FORMAT=format), ORIENTATION=1, TEXTPOS=1, /BORDER, POSITION=[0.85, 0.1, 0.87, 0.9])

IF (N_ELEMENTS(tstamp) GE 1) THEN t = TEXT(0.2,0.1,tstamp)

cst.hide=0
cst.Order,/BRING_FORWARD
END