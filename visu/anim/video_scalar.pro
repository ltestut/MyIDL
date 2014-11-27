PRO video_scalar, geo_in, proj=proj, limit=limit, $
                      f_start=f_start, n_frame=n_frame, scale=scale,  $
                      format=format,$
                      range=range,ncolors=ncolors,c_levels=c_levels,$
                      stream=stream, bathy=bathy,  output=output, _EXTRA=_EXTRA
; programme pour faire une animation d'un champ scalaire
; a partir d'une matrice geo.lat,geo.lon,geo.val

 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='mercator'
IF NOT KEYWORD_SET(scale) THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output=!mp4
IF NOT KEYWORD_SET(f_start) THEN f_start=30
IF NOT KEYWORD_SET(n_frame) THEN n_frame=10
IF NOT KEYWORD_SET(ncolors) THEN ncolors=16
IF NOT KEYWORD_SET(format) THEN format='(F5.1)'

 ;gestion de la table de couleur
LOADCT, 41, ncolors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)

 ;creation de la fenetre graphique
xsize = 1000
ysize = 800
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
t   = geo.jul
val = geo.val*scale
IF KEYWORD_SET(c_levels) THEN BEGIN
  range=[MIN(c_levels),MAX(c_levels)]
  levels=c_levels
ENDIF ELSE BEGIN  
 IF NOT KEYWORD_SET(range) THEN range=[MIN(val,/NAN),MAX(val,/NAN)]
 levels    = range[0]+(range[1]-range[0])/(ncolors-1)*INDGEN(ncolors)
ENDELSE
print,"Color range = ",range

 ;;dimension et localisation de l'image
dim_lon = MAX(lon,/NAN)-MIN(lon,/NAN)  ;dimension de l'image en degre
dim_lat = MAX(lat,/NAN)-MIN(lat,/NAN)
dim     = [dim_lon,dim_lat]
loc     = [MIN(lon,/NAN),MIN(lat,/NAN)]     ;localisation de l'image

IF KEYWORD_SET(bathy) THEN BEGIN
zvalue=[150,300,400,800,1000,2000]
zcolor=[240,200,150,100,50,10]
b   = CONTOUR(bathy.val,bathy.lon,bathy.lat,GRID_UNITS='deg',/OVERPLOT,$
               RGB_TABLE=0,C_VALUE=zvalue,$
                       RGB_INDICES=zcolor,/FILL)
b2  = CONTOUR(bathy.val,bathy.lon,bathy.lat,GRID_UNITS='deg',/OVERPLOT,$
               C_VALUE=zvalue,$
                        C_COLOR='white')
ENDIF

 ;trace le champ scalaire
field   = IMAGE(BYTSCL(val[*,*,f_start],MIN=range[0],MAX=range[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,$         
                ZRANGE=[range[0],range[1]],$
                POSITION=[0.05,0.06,0.95,0.80],$
                TRANSPARENCY=20,$
                /CURRENT ,$
                RGB_TABLE=rgb)



;field   = CONTOUR(val[*,*,f_start],lon,lat,GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=60.,$
;               C_VALUE=levels,RGB_TABLE=39,RGB_INDICES=BYTSCL(levels),/FILL,$
;                       POSITION=[0.1,0.1,0.76,0.76])
                       
                       
isoline = CONTOUR(val[*,*,f_start],lon,lat,GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=20.,$
                   C_VALUE=c_levels,C_LABEL_SHOW=0,LABEL_FORMAT=format,C_COLOR='black')

;trace la colorbar.
;cb       = colorbar(target=field, ORIENTATION=1, POSITION=[0.86, 0.20, 0.88, 0.80], /normal, $
;                     TEXTPOS=1,FONT_SIZE=12, $
;                     TITLE='Elevation ($cms^{-1}$)')

cb = COLORBAR(TARGET=field, /BORDER_ON, $
      POSITION=[0.1, 0.88, 0.9, 0.93],$
      TICKNAME=STRING(levels,FORMAT=format))



;m  = MAP(proj,LIMIT=limit,FILL_COLOR='white',/OVERPLOT,TRANSPARENCY=0)
;c  = MAPCONTINENTS(FILL_COLOR="antique white",/COUNTRIES,TRANSPARENCY=0,_EXTRA=_EXTRA)

; ;creation de la projection
;m   = MAP(proj,LIMIT=limit, /CURRENT, $
;          ;GRID_LATITUDE=1,GRID_LONGITUDE=1,$
;          BOX_AXES=1,$
;          title='Title')
;g    = m.MAPGRID
;m.mapgrid.order, /send_to_back


;st    =op_julval(julcut(load_cmb(/SLEV),DMIN=t[f_start],DMAX=t[f_start+n_frame]),/MOY)
;date_label=default_time_axis(tmin, tmax, t[f_start], t[f_start+n_frame]) ;renvoie le date_label par defaut
;
;p     =PLOT(st[0:1].jul, st[0:1].val,POSITION=[[0.1,0.8,0.8,0.95]],/CURRENT,$
;      XTICKFORMAT='LABEL_DATE',YRANGE=[-100.,100.],$
;      TITLE='Niveau de la mer a CMB',XTITLE='Days',YTITLE='H(cm)',$
;      XRANGE=[t[f_start],t[f_start+n_frame]],XSTYLE=1)

  ;place la legende et un sous-titre
legend   = text(0.05, 0.03, 'Date : '+print_date(t[f_start],/SINGLE), font_size=15)
sub      = [geo.info, geo.filename]
subtitle = text(0.05, 0.00, sub, /normal, font_size=8)

   
 ;Make the continental outlines to the top layer of the graphic.
;c.order, /bring_to_front
   
w.refresh
   
   ; Create the video object and add metadata.
video_file = output
video      = idlffvideowrite(video_file)
video.setmetadata, 'title', 'Barotropic elevation from tugo'
video.setmetadata, 'artist', 'L. Testut, LEGOS'
   
   ; Initialize the video stream. 
framerate = 1. ; the playback speed in frames per second
stream    = video.addvideostream(xsize, ysize, framerate)
   
   ; Write the current visualization as the first frame of the video.
timestamp = video.put(stream, w.copywindow())
help, timestamp
   
   ;parcours le temps
FOR i=f_start+1,f_start+n_frame DO BEGIN
  field.setdata, BYTSCL(val[*,*,i],MIN=range[0],MAX=range[1],/NAN),lon,lat
  isoline.setdata, val[*, *, i],lon,lat
  ;p.SetData,st[0:i].jul,st[0:i].val
  legend.string = 'Date : '+print_date(t[i],/SINGLE)
  timestamp = video.put(stream, w.copywindow())
  help, timestamp
endfor
   
   ; Destroy video object -- needed to close video file.
video.cleanup
print, 'File "' + video_file + '" written to current directory.'
END
write_video, /close, handle=h