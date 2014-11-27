FUNCTION create_ncdf_st_tide, latitude=latitude, longitude=longitude, bathymetrie=bathymetrie, nwave=nwave
; creer un structure qui contient les elements necessaires a la creation d'un netcdf de type tide LEGOS
; lon          => matrice de taille (nx,ny)
; lat          => matrice de taille (nx,ny)
; bathymetrie  => matrice de taille (nx,ny)

IF NOT KEYWORD_SET(nwave) THEN nwave=10

nx = N_ELEMENTS(longitude[*,0])
ny = N_ELEMENTS(longitude[0,*])

nw = nwave
nl = 1 ;number of tidal constituent of the simulation

; construction d'une structure de type 
st  = {nx:0, ny:0, nw:0, nl:0, lon:DBLARR(nx,ny),  lat:DBLARR(nx,ny), spectrum:STRARR(nw), ha:FLTARR(nx,ny,nw), hg:FLTARR(nx,ny,nw),ua:FLTARR(nx,ny,nw), ug:FLTARR(nx,ny,nw),$
       va:FLTARR(nx,ny,nw), vg:FLTARR(nx,ny,nw), bathy:FLTARR(nx,ny), lon_min:MIN(longitude,/NAN),lon_max:MAX(longitude,/NAN), lat_min:MIN(latitude,/NAN), lat_max:MAX(latitude,/NAN)}

; dimensions
st.nx     = nx ;number of longitude grid point
st.ny     = ny ;number of latitude grid point
st.nw     = nw ;
st.nl     = nl ;number of tidal constituent of the simulation
st.lon    = longitude 
st.lat    = latitude
IF KEYWORD_SET(bathymetrie) THEN st.bathy  = bathymetrie
 

; variables


RETURN, st
END