;c LECTURE DES FICHIERS (MATRICE DE DIM 3 [X,Y,Temps])
;GOTO, DESSIN
read_netcdf,'lat',Lat,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
read_netcdf,'lon',Lon,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
read_netcdf,'time',T,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
read_netcdf,'h',H,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'

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
Nc=1
 ;; N_ELEMENTS(H[0,0,*]) 
xtime=INDGEN(NC)
xcrd=[FLOOR(2*(70.-40.))       ,FLOOR(2*(60.-40.))]
ycrd=[FLOOR(2*(-49.5+57.5)),FLOOR(2*(-55.+57.5))]
zr= [-1,1]
set_plot, 'X'
device,retain=2,decomposed=0
loadct,0
!P.FONT=0
!P.MULTI=[0,1,1]
TX=300
TY=300
window,0,title='ANIMATION',XSIZE=TX,YSIZE=TY
A=bytarr(TX,TY,Nc)
TH=2

Jmin=JULDAY(1,1,1950,0,0,0)+16801.
date_label= LABEL_DATE(DATE_FORMAT = ['%M', '%Y'])

a1 = abs(indice_lat-(FIX(indice_lat)))*abs(indice_lon-(FIX(indice_lon)))*H[(FIX(indice_lat)),(FIX(indice_lon)),*]
a2 = abs(indice_lat-(FIX(indice_lat)+1))*abs(indice_lon-(FIX(indice_lon)))*H[(FIX(indice_lat)+1),(FIX(indice_lon)),*]
a3 = abs(indice_lat-(FIX(indice_lat)))*abs(indice_lon-(FIX(indice_lon)+1))*H[(FIX(indice_lat)),(FIX(indice_lon)+1),*]
a4 = abs(indice_lat-(FIX(indice_lat)+1))*abs(indice_lon-(FIX(indice_lon)+1))*H[(FIX(indice_lat)+1),(FIX(indice_lon)+1),*]

PLOT, a1+a2+a3+a4
  title    = title, subtitle = ''   ,$
  xtitle   = '',  ytitle   = ''   ,$
  xstyle   = 1 ,  ystyle   = 2    ,$
  xrange   = [0,size_T]

;  yrange   = [0,size_Y]
;  XTICKFORMAT   = ['LABEL_DATE'],$
;  XTICKUNITS    = ['Year'],$                
;  XTICKINTERVAL = 2    ,$
;  XTICKS        = 0    ,$  
;  XTICKLEN      = 1    ,$
;  XGRIDSTYLE    = 1  ,$
;  XTICKLAYOUT   = 0    ,$
;  psym  = 0	,$
  thick = 1



END
