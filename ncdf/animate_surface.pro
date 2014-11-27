;c LECTURE DES FICHIERS (MATRICE DE DIM 3 [X,Y,Temps])

rep_data = '/data/tmp1m/maraldi/convert/'
nom_du_fichier = rep_data + 'kerguelen02-2001.02.huv.nc'

read_netcdf,'lat',Lat,f=nom_du_fichier
read_netcdf,'lon',Lon,f=nom_du_fichier
read_netcdf,'time',T,f=nom_du_fichier
read_netcdf,'h',H,f=nom_du_fichier

X =  FLTARR(N_ELEMENTS(H[*,0,0]))
Y =  FLTARR(N_ELEMENTS(H[0,*,0]))

size_X = N_ELEMENTS(H[*,0,0])
size_Y = N_ELEMENTS(H[0,*,0])
size_T = N_ELEMENTS(H[0,0,*])

lat_min = MIN(Lat[0,*,0],/NAN) 
lat_max = MAX(Lat[0,*,0],/NAN)
lon_min = MIN(Lon[*,0,0],/NAN)
lon_max = MAX(Lon[*,0,0],/NAN)
t_min   = MIN(T[0,0,*],/NAN)
t_max   = MAX(T[0,0,*],/NAN)

tab_lat = lat_min  + INDGEN(size_X)*(lat_max-lat_min)/size_X
tab_lon = lon_min + INDGEN(size_Y)*(lon_max-lon_min)/size_Y

;data_lat doit avoir une valeur comprise entre lat_min et lat_max
;data_lon doit avoir une valeur comprise entre lon_min et lon_max
data_lat = -49.345000
data_lon = 70.220000
; attention Indice_lat et Indice_lon ne sont pas des entiers! Il faut interpoler avec "leur partie entiere", et "leur partie entiere+1"
indice_lat = (data_lat-lat_min) * size_X/(lat_max-lat_min)
indice_lon = (data_lon-lon_min) * size_Y/(lon_max-lon_min)



DESSIN: print,'dessin'
Nc=10
;; N_ELEMENTS(H[0,0,*]) 
xtime=INDGEN(NC)
zr= [-1,1]

set_plot, 'X'

;IF (((!D.Name EQ 'X') OR (!D.NAME EQ 'MAC')) $
;AND (!D.N_Colors GE 256L)) THEN $
;DEVICE, True_Color=24, decompose=0 $
;ELSE BEGIN & window, colors=100 & wdelete & $
;device, pseudo_color=8 & ENDELSE

window, colors=100 & wdelete
if !d.n_colors gt 256 then device, decomposed = 0 $
ELSE device, pseudo_color=8
device,retain=2,decomposed=0
loadct,39
tvlct, rouge,vert,bleu, /get
coefpalit= 1
key_portrait = 0
!P.FONT=0
!P.MULTI=[0,1,1]
;TX=300
;TY=300
TX=400
TY=400
window,0,title='ANIMATION',XSIZE=TX,YSIZE=TY
A=bytarr(TX,TY,Nc)
TH=2


Jmin=JULDAY(1,1,1950,0,0,0)+16801.
date_label= LABEL_DATE(DATE_FORMAT = ['%M', '%Y'])

FOR I=0,Nc-1 DO BEGIN  
    h_min = MIN(H[*,*,I],/NAN)
    h_max = MAX(H[*,*,I],/NAN)
ENDFOR


FOR I=0,Nc-1 DO BEGIN   
    CONTOUR, H[*,*,I], tab_lat, tab_lon,  $
      nlevels=50, c_colors=indgen(50), $
      TITLE = 'Hauteur de mer calculée', $
      XTITLE = 'Longitude', YTITLE = 'Latitude', $
      ;XRANGE = tab_lon, YRANGE = tab_lat
      /cell_fill
;SHADE_SURF, H[*,*,I], tab_lat, tab_lon, $
;ZRANGE=[h_min-0.1,h_max+0.1], $
;TITLE='Hauteur de mer calculée', $
;XTITLE='Latitude', YTITLE='Longitude', ZTITLE='Hauteur'
   A[0,0,I]=TVRD()
ENDFOR

;; Mise a l'echelle des valeurs entre 0 et 255
Nx  = N_ELEMENTS(A[*,0,0])
Ny  = N_ELEMENTS(A[0,*,0])
Nt  = N_ELEMENTS(A[0,0,*])
  
;; Initialize XINTERANIMATE:
XINTERANIMATE, SET=[Nx, Ny, Nt] 
;; Load the images into XINTERANIMATE:
FOR I=0,(Nt-1) DO XINTERANIMATE, FRAME = I, IMAGE = A[*,*,I]
;; Play the animation: 
XINTERANIMATE, /KEEP_PIXMAPS

FIN: print,'FIN'

END
