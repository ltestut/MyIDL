PRO read_netcdf, varname, output_var, filename=fic, nz_max=nz_max



IF (N_PARAMS() EQ 0) THEN BEGIN
 print, "USAGE:'
 print, "read_netcdf, varname, output_var, file=file, nz_max=nz_max "
 print, ""
 print, "  pour la lecture de .nc sortie de TUGO"
 print, ""
 print, "=> read_ncdf, 'h', IBD, file='toto.nc', nz_max=100 "
RETURN
ENDIF

print, fic
id=NCDF_OPEN(fic)

id_x=NCDF_DIMID(id,'x')
id_y=NCDF_DIMID(id,'y')
id_t=NCDF_DIMID(id,'time_counter')

NCDF_DIMINQ, id, id_x, x, Nx
NCDF_DIMINQ, id, id_y, y, Ny
NCDF_DIMINQ, id, id_t, t, Nt

flag=1.e+35

varid=NCDF_VARID(id,varname)
NCDF_VARGET, id,varid, output_var_raw

;taille de la variable de sortie
s = SIZE(output_var_raw)

IF KEYWORD_SET(nz_max) THEN BEGIN
   IF (s[0] EQ 1) THEN output_var=output_var_raw[0:nz_max-1]  ;on diminue la taille su tableau si trop grand
   IF (s[0] EQ 2) THEN output_var=output_var_raw 
   IF (s[0] EQ 3) THEN output_var=output_var_raw[*,*,0:nz_max-1]  ;on diminue la taille su tableau si trop grand
   ENDIF ELSE BEGIN 
   output_var=output_var_raw 
ENDELSE

help,output_var_raw,output_var
print,"Extraction de la variable : ",varname,' => var_id =',STRCOMPRESS(varid,/REMOVE_ALL), ' var[0] =',output_var_raw[0] 
print,"Extraction de la variable : ",varname,' => var_id =',STRCOMPRESS(varid,/REMOVE_ALL), ' var[0] =',output_var[0] 

IF (s[0] EQ 3) THEN BEGIN
   IFLAG=WHERE(ABS(output_var) ge 500 ,count)
   IF (count GE 1) THEN output_var[IFLAG]=!VALUES.F_NAN
ENDIF
NCDF_CLOSE,id 

END
