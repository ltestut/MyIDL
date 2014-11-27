FUNCTION ncdf_read_dim, name1=name1, name2=name2, ncdf_id=ncdf_id
; Equivalent à la fonction C read_dim. Permet de lire une dimension de netcdf qui porte le name1 ou name2
; EX :  dim_x= ncdf_read_dim(NAME1='X', NAME2='x', NCDF_ID=fid)

dim_id = NCDF_DIMID(ncdf_id, name1)
IF (dim_id EQ -1 ) THEN BEGIN
  dim_id = NCDF_DIMID(ncdf_id, name2)
  IF (dim_id EQ -1 ) THEN BEGIN
    printf, 'Impossible to find dimension '+name1+' in the netcdf file'
    exit
  ENDIF
ENDIF
NCDF_DIMINQ, ncdf_id, dim_id, dim_name, dim
return, dim
END
