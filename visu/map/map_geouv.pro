PRO map_geouv, geo_in, proj=proj, limit=limit, save=save, frame=frame,$
                      stream=stream, $
                      cst=cst, bathy=bathy,  output=output, _EXTRA=_EXTRA
; programme pour tracer un champ de vecteurs


 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='stereo'
IF NOT KEYWORD_SET(nlev) THEN nlev=10
IF NOT KEYWORD_SET(scale) THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output=!png
IF NOT KEYWORD_SET(frame) THEN frame=1



 ;determnation du type et des limites de la geomatrice
IF KEYWORD_SET(limit) THEN BEGIN
 geo = geocut(geo_in,limit=limit)
ENDIF ELSE BEGIN
 geo = geo_in
ENDELSE
glimit   = get_geo_lim(geo)
limit    = change2idllimit(glimit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 


 ;etablissement du champ de vecteur a tracer
s   = SIZE(geo.u,/N_DIMENSIONS)
lon = geo.lon
lat = geo.lat
IF (s EQ 2) THEN BEGIN               ;cas d'une matrice (nx,ny) 
 u = geo.u*scale
 v = geo.v*scale
ENDIF ELSE IF (s EQ 3) THEN BEGIN   ;cas d'une matrice (nx,ny,nt)
 t = geo.jul[frame]
 u = geo.u[*,*,frame]*scale
 v = geo.v[*,*,frame]*scale
 IF NOT KEYWORD_SET(title) THEN title=print_date(t,/SINGLE)
ENDIF

  ; Turn off updates in the window until all plots are complete.
IF KEYWORD_SET(current) THEN BEGIN
w=window
ENDIF ELSE BEGIN
w = window(WINDOW_TITLE="MAP_GEOUV",FONT_SIZE=18,$
            POSITION=[0.1,0.1,0.8,0.8],$
            TITLE=title,$
            _EXTRA=_EXTRA)
ENDELSE
w.refresh, /disable
m      = MAP(proj,LIMIT=limit)
g      = m.MAPGRID

;m.mapgrid.order, /send_to_back
IF KEYWORD_SET(cst) THEN BEGIN
 coast=POLYLINE(cst.lon,cst.lat,CONNECTIVITY=cst.con,TARGET=m,$
           COLOR='blue',/DATA,THICK=1,$
           LINESTYLE=2,$
           /OVERPLOT) 
ENDIF ELSE BEGIN
 coast    = MAPCONTINENTS()
ENDELSE


IF KEYWORD_SET(bathy) THEN BEGIN
b   = CONTOUR(bathy.val,bathy.lon,bathy.lat,GRID_UNITS='deg',/OVERPLOT,$
               RGB_TABLE=0,C_VALUE=[50,150,500,1000,3000],$
                       RGB_INDICES=[255,200,150,100,50],/FILL)
b2  = CONTOUR(bathy.val,bathy.lon,bathy.lat,GRID_UNITS='deg',/OVERPLOT,$
               C_VALUE=[50,150,500,1000,3000],$
                        C_COLOR='white')

ENDIF

IF NOT KEYWORD_SET(stream) THEN BEGIN
 ;plot the vector field
v = vector(u, v, lon, lat, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=50,$
      RGB_TABLE=26, AUTO_COLOR=1, HEAD_SIZE=1., $
      X_SUBSAMPLE=4,Y_SUBSAMPLE=4,$
      MIN_VALUE=5.,AUTO_RANGE=[0.,50.])
v.Refresh, /DISABLE
ENDIF ELSE BEGIN
 ;Display the streamlines 
v   = STREAMLINE(u,v,lon,lat, /OVERPLOT, TRANSPARENCY=50,$
         STREAMLINE_STEPSIZE=0.8, STREAMLINE_NSTEPS=30 ,$
         ARROW_COLOR='grey', ARROW_THICK=2., $
         RGB_TABLE=33, AUTO_COLOR=1, THICK=3,$
         X_SUBSAMPLE=4,Y_SUBSAMPLE=4,$
         MIN_VALUE=1.)
ENDELSE
   ; Display a subtitle.
str = [geo.info, geo.filename]
subtitle = text(0.1, 0.125, str, /normal, font_size=6)


   ; Display a colorbar.
cb = colorbar(target=v, position=[0.2, 0.15, 0.90, 0.175], /normal, $
        font_size=12, title='Velocity ($cms^{-1}$)')


v.Refresh
 ; Let the window update.
w.refresh
   
   ; Optionally save the visualization to a JPEG file.
IF KEYWORD_SET(save) then BEGIN
PRINT,output
w.save, output, resolution=100
ENDIF
END