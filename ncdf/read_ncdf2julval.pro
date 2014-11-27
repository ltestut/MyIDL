FUNCTION read_ncdf2julval, fic, lat, lon

; find the identifiant of the file (id) of the dimensions (id_x,id_y,id_t) and
; of the variables (id_jul,id_var)
id     = NCDF_OPEN(fic)
id_x   = NCDF_DIMID(id,'x')
id_y   = NCDF_DIMID(id,'y')
id_t   = NCDF_DIMID(id,'time_counter')
id_jul = NCDF_VARID(id,'time')
id_var = NCDF_VARID(id,'h')

; Inquire for dimensions of the field
NCDF_DIMINQ, id, id_x, x, Nx
NCDF_DIMINQ, id, id_y, y, Ny
NCDF_DIMINQ, id, id_t, t, Nt

; Create array
tab_jul= FLTARR(Nt)
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
