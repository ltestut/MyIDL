PRO video_track, track, proj=proj, limit=limit, f_start=f_start, n_frame=n_frame, $
                      stream=stream, bathy=bathy,  output=output, _EXTRA=_EXTRA
; programme pour faire une animation d'un champ de vecteurs
; a partir d'une matrice geo.u, geo.v

 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='stereo'
IF NOT KEYWORD_SET(nlev) THEN nlev=10
IF NOT KEYWORD_SET(scale) THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output='/home/testut/Desktop/idl.avi'
IF NOT KEYWORD_SET(f_start) THEN f_start=0
IF NOT KEYWORD_SET(n_frame) THEN n_frame=100


 ;creation de la fenetre graphique
xsize = 1000
ysize = 800
w     = window(dimensions=[xsize,ysize])
w.refresh, /disable

 ;determnation des limites geographiques
IF NOT KEYWORD_SET(limit) THEN BEGIN
limit   = get_geo_lim(track.pt)
ENDIF
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

 ;recuperation des variables a tracer
lon = track.pt.lon
lat = track.pt.lat
t   = track.pt.jul
u   = track.pt.u*scale
v   = track.pt.v*scale

 ;creation de la projection
m   = MAP(proj,LIMIT=limit, /CURRENT, $
          GRID_LATITUDE=1,GRID_LONGITUDE=1,BOX_AXES=1,$
          title='Courant (pression+vent) de la simu B9B1')
g    = m.MAPGRID
m.mapgrid.order, /send_to_back

 ;trace la ligne de cote
 ;coast    = MAPCONTINENTS()
cst   =load_scan(/DOM,/ANT)
coast =POLYLINE(cst.lon,cst.lat,CONNECTIVITY=cst.con,TARGET=m,$
          COLOR='black',/DATA,THICK=2,$
          /OVERPLOT) 

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

 ;trace le champ de vecteur
field = vector(REFORM(u[f_start,*]), REFORM(v[f_start,*]), lon, lat, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=50,$
                RGB_TABLE=26, AUTO_COLOR=1, HEAD_SIZE=0.2, $
                X_SUBSAMPLE=2,Y_SUBSAMPLE=2,$
                MIN_VALUE=0.,AUTO_RANGE=[0.,20.],$
                DATA_LOCATION='tail',$
                POSITION=[0.1,0.1,0.8,0.7])


;st    =op_julval(julcut(load_cmb(/SLEV),DMIN=t[f_start],DMAX=t[f_start+n_frame]),/MOY)
;date_label=default_time_axis(tmin, tmax, t[f_start], t[f_start+n_frame]) ;renvoie le date_label par defaut
;
;p     =PLOT(st[0:1].jul, st[0:1].val,POSITION=[[0.1,0.8,0.8,0.95]],/CURRENT,$
;      XTICKFORMAT='LABEL_DATE',YRANGE=[-100.,100.],$
;      TITLE='Niveau de la mer a CMB',XTITLE='Days',YTITLE='H(cm)',$
;      XRANGE=[t[f_start],t[f_start+n_frame]],XSTYLE=1)

  ;place la legende et un sous-titre
legend   = text(0.05, 0.04, 'Date : '+print_date(REFORM(t[f_start,0]),/SINGLE), font_size=15)
sub      = [track.filename]
subtitle = text(0.05, 0.01, sub, /normal, font_size=8)

 ;trace la colorbar.
cb       = colorbar(target=field, ORIENTATION=1, POSITION=[0.86, 0.20, 0.88, 0.80], /normal, $
                     TEXTPOS=1,FONT_SIZE=12, $
                     TITLE='Velocity ($cms^{-1}$)')
   
   ; Make the continental outlines to the top layer of the graphic.
coast.order, /bring_to_front
   
w.refresh
   
   ; Create the video object and add metadata.
video_file = output
video      = idlffvideowrite(video_file)
video.setmetadata, 'title', 'Mertz barotropic current from tugo'
video.setmetadata, 'artist', 'L. Testut, LEGOS'
   
   ; Initialize the video stream. 
framerate = 4. ; the playback speed in frames per second
stream    = video.addvideostream(xsize, ysize, framerate)
   
   ; Write the current visualization as the first frame of the video.
timestamp = video.put(stream, w.copywindow())
help, timestamp
   
   ;parcours le temps
FOR i=f_start+1,f_start+n_frame DO BEGIN
  field.setdata, REFORM(u[i,*]),REFORM(v[i,*]),lon,lat
  ;p.SetData,st[0:i].jul,st[0:i].val
  legend.string = 'Date : '+print_date(t[i,0],/SINGLE)
  timestamp = video.put(stream, w.copywindow())
  help, timestamp
endfor
   
   ; Destroy video object -- needed to close video file.
video.cleanup
print, 'File "' + video_file + '" written to current directory.'
END
