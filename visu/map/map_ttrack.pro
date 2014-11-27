PRO map_ttrack, track, track2, track3, limit=limit, proj=proj, scale=scale, frame=frame,$      
                         id=id, output=output, _EXTRA=_EXTRA
; Programme pour tracer les donnees d'une structure de type ttrack 
; issue de geo2ttrack

;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='Polar Stereographic'
IF NOT KEYWORD_SET(scale) THEN scale=1.
IF NOT KEYWORD_SET(output) THEN output=!png
IF NOT KEYWORD_SET(frame) THEN frame=0
IF NOT KEYWORD_SET(limit) THEN limit = get_seg_lim(track.pt) 
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

 ;etablissement du champ de vecteur a tracer
s   = SIZE(track.pt.u,/N_DIMENSIONS)
lon = track.pt.lon
lat = track.pt.lat
IF (s EQ 1) THEN BEGIN               ;cas d'une matrice (nx,ny)
 u   = track.pt.u*scale
 v   = track.pt.v*scale
ENDIF ELSE IF (s EQ 2) THEN BEGIN   ;cas d'une matrice (nx,ny,nt)
 t   = track.pt[0].jul[frame]
 u   = track.pt.u[frame]*scale
 v   = track.pt.v[frame]*scale
 IF NOT KEYWORD_SET(title) THEN title=print_date(t,/SINGLE)
ENDIF
PRINT,"[MIN-MAX] (U,V) : [",min(u,MAX=mu),'-',mu,']','[',min(v,MAX=mv),'-',mv,']'

  ; Turn off updates in the window until all plots are complete.
w = WINDOW(WINDOW_TITLE='MAP_TTRACK',FONT_SIZE=18,$
            POSITION=[0.1,0.1,0.8,0.8],$
            TITLE=title,$
            _EXTRA=_EXTRA)
;w.refresh, /disable
m      = MAP(proj,LIMIT=limit, /CURRENT)
g      = m.MAPGRID

p=POLYLINE(lon,lat,TARGET=map,$
           COLOR='blue',/DATA,THICK=1,$
           LINESTYLE=2,$
           /OVERPLOT)



;m.mapgrid.order, /send_to_back
IF KEYWORD_SET(cst) THEN BEGIN
 coast=POLYLINE(cst.lon,cst.lat,CONNECTIVITY=cst.con,TARGET=m,$
           COLOR='blue',/DATA,THICK=1,$
           LINESTYLE=2,$
           /OVERPLOT) 
ENDIF ELSE BEGIN
;coast    = MAPCONTINENTS(/HIRES)
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

 ;plot the vector field
field1 = vector(u, v, lon, lat, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=50,$
      ;RGB_TABLE=26, AUTO_COLOR=1, HEAD_SIZE=0.2, $
      COLOR='black',$
      ;X_SUBSAMPLE=1,Y_SUBSAMPLE=1,$
      ;MIN_VALUE=1.,AUTO_RANGE=[0.,50.],$
      DATA_LOCATION='tail')


CASE N_PARAMS() OF
   2 : BEGIN
         s2   = SIZE(track2.pt.u,/N_DIMENSIONS)
         lon2 = track2.pt.lon
         lat2 = track2.pt.lat
           IF (s EQ 1) THEN BEGIN               ;cas d'une matrice (nx,ny)
             u2   = track2.pt.u*scale
             v2   = track2.pt.v*scale
           ENDIF ELSE IF (s EQ 2) THEN BEGIN   ;cas d'une matrice (nx,ny,nt)
             t2   = track2.pt[0].jul[frame]
             u2   = track2.pt.u[frame]*scale
             v2   = track2.pt.v[frame]*scale
          ENDIF
         PRINT,"[MIN-MAX] (U2,V2) : [",min(u2,MAX=mu2),'-',mu2,']','[',min(v2,MAX=mv2),'-',mv2,']'
       field2 = vector(u2, v2, lon2, lat2, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=50,$
                   COLOR='blue', AUTO_COLOR=0, HEAD_SIZE=0.2, $
                   ;X_SUBSAMPLE=1,Y_SUBSAMPLE=1,$
                   ;MIN_VALUE=1.,AUTO_RANGE=[0.,50.],$
                   DATA_LOCATION='tail')
       END
   3 : BEGIN
         s2   = SIZE(track2.pt.u,/N_DIMENSIONS)
         lon2 = track2.pt.lon
         lat2 = track2.pt.lat
           IF (s EQ 1) THEN BEGIN               ;cas d'une matrice (nx,ny)
             u2   = track2.pt.u*scale
             v2   = track2.pt.v*scale
           ENDIF ELSE IF (s EQ 2) THEN BEGIN   ;cas d'une matrice (nx,ny,nt)
             t2   = track2.pt[0].jul[frame]
             u2   = track2.pt.u[frame]*scale
             v2   = track2.pt.v[frame]*scale
          ENDIF
         PRINT,"[MIN-MAX] (U2,V2) : [",min(u2,MAX=mu2),'-',mu2,']','[',min(v2,MAX=mv2),'-',mv2,']'
       field2 = vector(u2, v2, lon2, lat2, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=50,$
                   COLOR='blue', AUTO_COLOR=0, HEAD_SIZE=0.2, $
                   ;X_SUBSAMPLE=1,Y_SUBSAMPLE=1,$
                   ;MIN_VALUE=1.,AUTO_RANGE=[0.,50.],$
                   DATA_LOCATION='tail')
         s3   = SIZE(track3.pt.u,/N_DIMENSIONS)
         lon3 = track3.pt.lon
         lat3 = track3.pt.lat
           IF (s EQ 1) THEN BEGIN               ;cas d'une matrice (nx,ny)
             u3   = track3.pt.u*scale
             v3   = track3.pt.v*scale
           ENDIF ELSE IF (s EQ 2) THEN BEGIN   ;cas d'une matrice (nx,ny,nt)
             t3   = track3.pt[0].jul[frame]
             u3   = track3.pt.u[frame]*scale
             v3   = track3.pt.v[frame]*scale
          ENDIF
         PRINT,"[MIN-MAX] (U3,V3) : [",min(u3,MAX=mu3),'-',mu3,']','[',min(v3,MAX=mv3),'-',mv3,']'
       field3 = vector(u3, v3, lon3, lat3, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=50,$
                   COLOR='red', AUTO_COLOR=0, HEAD_SIZE=0.2, $
                   ;X_SUBSAMPLE=1,Y_SUBSAMPLE=1,$
                   ;MIN_VALUE=1.,AUTO_RANGE=[0.,50.],$
                   DATA_LOCATION='tail')
       END
ENDCASE

   ; Display a subtitle.
str      = [track.filename]
subtitle = text(0.1, 0.125, str, /normal, font_size=6)


   ; Display a colorbar.
cb = colorbar(target=field1, position=[0.2, 0.15, 0.90, 0.175], /normal, $
        font_size=12, title='Velocity ($cms^{-1}$)')


 ; Let the window update.
w.refresh
   
   ; Optionally save the visualization to a JPEG file.
IF KEYWORD_SET(save) then BEGIN
PRINT,output
w.save, output, resolution=100
ENDIF
END
