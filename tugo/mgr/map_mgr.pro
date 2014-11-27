PRO map_mgr, mgr_in, limit=limit, zone=zone, proj=proj, bathy=bathy, $
                    range=range, ncolors=ncolors, title=title, symsize=simsize, $
                    label=label ,number=number, scale=scale, $
                    output=output, resolution=resolution, buffer=buffer, wave=wave, tide=tide,$
                    _EXTRA=_EXTRA
; routine qui trace les localisations des stations d'une structure de type mgr
; elle permet de tracer aussi le noms et les valeurs d'amplitude/phase de certaines ondes.
; wave='M2'  ==> affiche a cote du nom de la station l'amplitude et la phase de l'onde
; tide=geoM2    => permet de mettre un fond de carte l'amplitude ou la phase issue d'un modele
; /LABEL        : plot the name, amplitude or phase at the mgr location
;   => /NUMBER  : use number as a label

IF NOT KEYWORD_SET(title) THEN title='MAP '
IF NOT KEYWORD_SET(resolution) THEN resolution=150

IF KEYWORD_SET(WAVE) THEN title=title+wave

IF NOT KEYWORD_SET(limit) THEN BEGIN
 ;determination des min/max des coordonnees geographique
 mgr      = mgr_in
 limit    = get_mgr_limit(mgr)
 dl       = 1. ;on ajout 2deg de chaque cote des limites
 limit    = [limit[0]-dl,limit[1]+dl,limit[2]-dl,limit[3]+dl]
ENDIF
mgr      = cut_mgr(mgr_in,LIMIT=limit) 
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin]

IF NOT KEYWORD_SET(proj)    THEN proj='mercator'
IF NOT KEYWORD_SET(ncolors) THEN ncolors=16
IF NOT KEYWORD_SET(symsize) THEN symsize=1.
IF NOT KEYWORD_SET(scale)   THEN scale= 1.
IF KEYWORD_SET(wave)        THEN range=minmax_wave_mgr(mgr,WAVE=wave)*scale

IF KEYWORD_SET(label) THEN BEGIN
   mgr_label = STRCOMPRESS(mgr.name,/REMOVE_ALL)
   IF KEYWORD_SET(number) THEN mgr_label = STRING(INDGEN(N_ELEMENTS(mgr.name))+1,FORMAT='(I2)')
  ; mgr_label = ''
   IF KEYWORD_SET(wave) THEN BEGIN
    nsta   = N_ELEMENTS(mgr_label)
    id     = wave_index(mgr,wave)
    FOR i=0,nsta-1 DO BEGIN
     
     mgr_label[i] = mgr_label[i]+STRCOMPRESS(STRING(mgr[i].amp[id[i]]*scale,FORMAT='(F5.1)'))+'/'$
                   +STRCOMPRESS(STRING(mgr[i].pha[id[i]],FORMAT='(F5.1)'))
;     mgr_label[i] = STRCOMPRESS(STRING(mgr[i].pha[id[i]],FORMAT='(F5.1)'))
    ENDFOR
   ENDIF
ENDIF 

;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;creation de la fenetre graphique
xsize = 1800
ysize = 1400
p_pos = [0.15,0.15,0.85,0.85]
IF KEYWORD_SET(buffer) THEN w  = window(dimensions=[xsize,ysize],/BUFFER) ELSE w = window(dimensions=[xsize,ysize])

;w.refresh, /disable
;gestion de la table de couleur
LOADCT, 13, NColors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)
TVLCT, rgb
symco = 'red' ;couleur par defaut des pts mgr 


m   = MAP(proj,POSITION=p_pos,LIMIT=limit,FILL_COLOR='white',$  
          /CURRENT,TRANSPARENCY=0,LABEL_SHOW=0,/BOX_AXES,$
          TITLE=title)
g   = MAPGRID(GRID_LONGITUDE = 1.,GRID_LATITUDE = 1., LINESTYLE='dot',COLOR='grey',LABEL_POSITION=0)
c   = MAPCONTINENTS(FILL_COLOR="antique white",/CONTINENTS,/HIRES)
IF KEYWORD_SET(label) THEN s = update_symbol_layer(SYMBOL(mgr.lon,mgr.lat,'o',LABEL_STRING=mgr_label,/DATA,/OVERPLOT),NAME='number') ELSE p   = PLOT(mgr.lon,mgr.lat,'+',/DATA,AXIS_STYLE=1,LINESTYLE=6,/OVERPLOT)

IF KEYWORD_SET(bathy) THEN BEGIN
 zvalue=[5,10,20,50,100,150,500]
 b  = CONTOUR(bathy.val,bathy.lon,bathy.lat,GRID_UNITS='deg',$
               C_VALUE=zvalue,C_LABEL_SHOW=0,$
               C_COLOR='grey',$
               /OVERPLOT)
ENDIF

;m.save,'mgr.kml'
;s.save,'mgr.kml'
m.order, /SEND_TO_BACK
g.Order, /SEND_TO_BACK
IF KEYWORD_SET(label) THEN s.Order, /BRING_TO_FRONT
c.order, /SEND_BACKWARD
w.refresh
  IF KEYWORD_SET(output) THEN BEGIN
    print,output
    w.Save, output, RESOLUTION=resolution
  ENDIF
END