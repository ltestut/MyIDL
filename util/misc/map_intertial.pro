PRO map_intertial, limit=limit, proj=proj, $
                    ncolors=ncolors, title=title, range=range ,$
                    output=output, resolution=resolution, buffer=buffer,$
                    _EXTRA=_EXTRA


;#######################################################################
;############  COMPUTATION PART : DEFINE&COMPUTE GRAPHIC VARIABLE ######
;#######################################################################
IF NOT KEYWORD_SET(title)         THEN title='MAP OF INERTIAL PERIOD (DAYS)'
IF NOT KEYWORD_SET(proj)          THEN proj='EQUIRECTANGULAR'
IF NOT KEYWORD_SET(scale)         THEN scale=1.
IF NOT KEYWORD_SET(ncolors)       THEN ncolors=10
IF NOT KEYWORD_SET(aspect_ratio)  THEN aspect_ratio=1
IF NOT KEYWORD_SET(val_format)    THEN val_format='(F5.1)'
IF NOT KEYWORD_SET(col)           THEN col=13
IF NOT KEYWORD_SET(resolution)    THEN resolution=150
IF NOT KEYWORD_SET(range)         THEN range=[1.,3*24.]
IF NOT KEYWORD_SET(limit)         THEN limit =[-180.,180.,-70.,70.]


 ;recuperation des variables a tracer et calcul du zrange et des niveaux
nx    = 360
ny    = 180
lon   = -180.+INDGEN(nx)
lat   = -90.+INDGEN(ny)
inan  =  WHERE(ABS(lat) LT 5.)
field = FLTARR(nx,ny) 

FOR i=0,ny-1 DO field[*,i]=ABS(12./sin(rad(lat[i]))) ;period 

field[*,inan]=!VALUES.F_NAN

;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;creation de la fenetre graphique
xsize = 1800
ysize = 1400
p_pos = [0.1,0.1,0.9,0.9]
IF KEYWORD_SET(buffer) THEN w  = window(dimensions=[xsize,ysize],/BUFFER) ELSE w = window(dimensions=[xsize,ysize])
w.refresh, /disable
;gestion de la table de couleur
LOADCT, 13, NColors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)
TVLCT, rgb

map_field  = IMAGE(BYTSCL(field,MIN=range[0],MAX=range[1],/NAN),GRID_UNITS='degrees',ASPECT_RATIO=aspect_ratio,/CURRENT,$
                   POSITION=p_pos,AXIS_STYLE=0,RGB_TABLE=rgb)

m           = MAP(proj,LIMIT=change2idllimit(limit),FILL_COLOR='white',/CURRENT,TRANSPARENCY=0,LABEL_SHOW=0,/BOX_AXES,$
                  POSITION=p_pos,TITLE=title)
g           = MAPGRID(GRID_LONGITUDE = 15.,GRID_LATITUDE = 15., LINESTYLE='dot',COLOR='grey',LABEL_POSITION=0)
c           = MAPCONTINENTS(FILL_COLOR="antique white",/CONTINENTS)

cb = COLORBAR(TARGET=map_field, /BORDER_ON, TITLE='M2 Tidal Misfits (cm)',TAPER=2,$
                                                     TICKNAME=STRING(range,FORMAT=col_format),$
                                                     TEXTPOS=0,FONT_SIZE=10., $
                                                      POSITION=[p_pos[0],0.1+p_pos[1]-0.03,p_pos[2],0.1+p_pos[1]-0.01])


;m.order, /SEND_TO_BACK
;g.Order, /SEND_TO_BACK
;c.order, /SEND_BACKWARD
w.refresh
  IF KEYWORD_SET(output) THEN BEGIN
    print,output
    w.Save, output, RESOLUTION=resolution
  ENDIF
END