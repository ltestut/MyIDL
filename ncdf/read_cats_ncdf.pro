FUNCTION read_cats_ncdf, file=file, var_name=var_name, nwave=nwave
; lecture de fichier netcdf de constituant de la maree du model CATS2008
; et mise dans une structure de type st_tide

;file_h='/data2/model/model_mertz/travail_en_cours/CATS08/hf.CATs2008_ll.nc'
;file_uv='/data2/model/model_mertz/travail_en_cours/CATS08/uv.CATs2008_ll.nc'

var_a_name=var_name+'a'
var_g_name=var_name+'p'

id   = NCDF_OPEN(file)      ; ouverture du fichier
info = NCDF_INQUIRE(id)       ; => renvoie les info sur le fichier NetCDF dans la structure info
NCDF_DIMINQ,id,0,n0,s0        ; renvoie le nom *n0* et taille *s0* de la dimension 0 : nx
NCDF_DIMINQ,id,1,n1,s1        ; renvoie le nom *n1* et taille *s1* de la dimension 1 : ny
NCDF_DIMINQ,id,2,n2,s2        ; renvoie le nom *n2* et taille *s2* de la dimension 2 : nc
NCDF_DIMINQ,id,3,n3,s3        ; renvoie le nom *n3* et taille *s3* de la dimension 3 : nct


FOR i=0, info.nvars-1, 1 DO BEGIN
  var_info=NCDF_VARINQ(id,i)
  IF STREGEX(var_info.name, 'lon', /BOOLEAN) THEN lon_name=var_info.name
  IF STREGEX(var_info.name, 'lat', /BOOLEAN) THEN lat_name=var_info.name
ENDFOR




; declaration des matrices
; ------------------------
const     = BYTARR(s2)
lon       = DBLARR(s0,s1)     ;x
lat       = DBLARR(s0,s1)     ;y
var_a        = FLTARR(s0,s1,s2)  ;H(x,y,c)
var_g        = FLTARR(s0,s1,s2)  ;H(x,y,c)

NCDF_VARGET, id, NCDF_VARID(id,'con'), const
NCDF_VARGET, id, NCDF_VARID(id,lon_name), lon
NCDF_VARGET, id, NCDF_VARID(id,lat_name), lat
NCDF_VARGET, id, NCDF_VARID(id,var_a_name), var_a
NCDF_VARGET, id, NCDF_VARID(id,var_g_name), var_g
NCDF_CLOSE,  id  ; fermeture du fichier

print,STRING(const)
;map_matrix,Hp[*,*,0],pal=13

id_flag_a=WHERE((var_a EQ 0) OR (var_a NE var_a), cnt)  ; TEST POUR TROUVER LES NaN : chercher ou le nombre n'es pas egal a lui même : c'est un NaN !
IF ( cnt GT 0 ) THEN var_a[id_flag_a]=!VALUES.F_NAN

id_flag_g=WHERE((var_g EQ 0) OR (var_g NE var_g), cnt)
IF ( cnt GT 0 ) THEN var_g[id_flag_g]=!VALUES.F_NAN


st_out=create_ncdf_st_tide(lat=lat, lon=lon, nwave=nwave)

IF (var_name EQ 'h') THEN BEGIN
st_out.ha=var_a
st_out.hg=var_g
ENDIF
IF (var_name EQ 'u') THEN BEGIN
st_out.ua=var_a
st_out.ug=var_g
ENDIF
IF (var_name EQ 'v') THEN BEGIN
st_out.va=var_a
st_out.vg=var_g
ENDIF

st_out.spectrum=string(const)

return, st_out

END