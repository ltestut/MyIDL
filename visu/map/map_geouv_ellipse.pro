PRO map_geouv_ellipse, geo_in, proj=proj, limit=limit, save=save, frame=frame,$
                      stream=stream, $
                      cst=cst, bathy=bathy,  output=output, _EXTRA=_EXTRA
; programme pour tracer un champ de vecteurs


 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='mercator'
IF NOT KEYWORD_SET(nlev) THEN nlev=10
IF NOT KEYWORD_SET(scale) THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output=!toto
IF NOT KEYWORD_SET(frame) THEN frame=1


 ;determnation du type et des limites de la geomatrice
IF KEYWORD_SET(limit) THEN BEGIN
 geo = geocut(geo_in,limit=limit)
ENDIF ELSE BEGIN
 geo = geo_in
ENDELSE
glimit   = get_geo_lim(geo)
limit    = change2idllimit(glimit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

geouv2ellipse,geo,a,b,phi


 ;etablissement du champ de vecteur a tracer
s   = SIZE(geo.u,/N_DIMENSIONS)
lon = geo.lon
lat = geo.lat

  
w = WINDOW(POSITION=[0.1,0.1,0.8,0.8],TITLE=title,_EXTRA=_EXTRA)
;w = WINDOW()

w.refresh, /disable
m      = MAP(proj,LIMIT=limit, /OVERPLOT)
g      = m.MAPGRID

;m.mapgrid.order, /send_to_back
;coast  = MAPCONTINENTS(FILL_COLOR="antique white",/COASTS,/OVERPLOT,TRANSPARENCY=0)



scale=10.
; Create ellipses within the data space.

FOR i=0,N_ELEMENTS(lon)-1,10 DO BEGIN
  FOR j=0,N_ELEMENTS(lat)-1,10 DO BEGIN
   print,i,j,lon[i],lat[j],a[i,j]*scale, b[i,j]*scale, phi[i,j]
 e = ELLIPSE(lon[i], lat[j], FILL_BACKGROUND=0,$
      MAJOR=a[i,j]*scale, MINOR=b[i,j]*scale, THETA=phi[i,j],/DATA)
 ENDFOR
ENDFOR
e.THICK = 2

;   ; Display a subtitle.
;str = [geo.info, geo.filename]
;subtitle = text(0.1, 0.125, str, /normal, font_size=6)


   ; Display a colorbar.
;cb = colorbar(target=v, position=[0.2, 0.15, 0.90, 0.175], /normal, $
;        font_size=12, title='Velocity ($cms^{-1}$)')


;v.Refresh
 ; Let the window update.
w.refresh
   
   ; Optionally save the visualization to a JPEG file.
IF KEYWORD_SET(save) then BEGIN
PRINT,output
w.save, output, resolution=100
ENDIF
END