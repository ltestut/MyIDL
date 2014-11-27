FUNCTION matrix2julval, Z, lat, lon, time, lat_coord=lat_coord, lon_coord=lon_coord 
; A FINIR
s    = SIZE(Z)
slat = SIZE(lat) 
Nt   = N_ELEMENTS(time)

;IF (slat[0] GT 1) THEN lat=lat[0,*] & lon=lon[] -> mis en commentaire le 19/12/2008 par NP
IF (slat[0] GT 1) THEN lat=lat[0,*] & lon=lon

Nlat = N_ELEMENTS(lat)
Nlon = N_ELEMENTS(lon)

;create julval struxture
st = create_julval(s[3])
tab_var= FLTARR(Nt)
var_h  = FLTARR(Nx,Ny,Nt)

; Read the time (id_jul) and sea level height (id_val) from the netcdf file
NCDF_VARGET, id, id_jul, tab_jul
NCDF_VARGET, id, id_var, var_h

; Interpolation of the id_val variable in the (lat,lon) point at each
; time step
FOR I=0,Nt-1 DO tab_var[I]=BILINEAR(var_h[*,*,I],lat,lon)

st=create_julval(Nt)
st.jul=tab_jul/(3600.*24)+JULDAY(01,01,1950,0,0,0)
st.val=tab_var

NCDF_CLOSE,id 

RETURN, st

END
