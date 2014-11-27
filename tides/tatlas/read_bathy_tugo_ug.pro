PRO read_bathy_tugo_ug
; read the bathymetry from the TUGO unstructured files.

 ;open netcdf file (.nc) and variable lon,lat
fid  = NCDF_OPEN(filename)     ; ouverture du fichier
NCDF_VARGET, fid, NCDF_VARID(fid,'lon')       ,  lon    ;lon(n)
NCDF_VARGET, fid, NCDF_VARID(fid,'lat')       ,  lat    ;lat(n)
NCDF_VARGET, fid, NCDF_VARID(fid,'bathymetry'),  bathy  ;bathy(n)

 ;recuperation des dimensions x et y
dim_x= N_ELEMENTS(lon[*,0]) ;ncdf_read_dim(NAME1='x', NAME2='X', NCDF_ID=fid)
dim_y= N_ELEMENTS(lon[0,*]) ;ncdf_read_dim(NAME1='y', NAME2='Y', NCDF_ID=fid)


END