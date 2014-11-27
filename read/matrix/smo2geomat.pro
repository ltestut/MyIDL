FUNCTION smo2geomat, filename, para=para, verbose=verbose
; lecture du fichier netcd de Surface Moyenne Oceanique et mise dans une structure de type geomat

IF NOT KEYWORD_SET(para) THEN para='smo'

id   = NCDF_OPEN(filename)    ; ouverture du fichier
info = NCDF_INQUIRE(id)       ; => renvoie les info sur le fichier NetCDF dans la structure info
NCDF_DIMINQ,id,0,n0,s0        ; renvoie le nom *n1* et taille *s1* de la dimension 1 : NbLatitudes
NCDF_DIMINQ,id,1,n1,s1        ; renvoie le nom *n2* et taille *s2* de la dimension 2 : NbLongitudes

geo       = create_geomat(s1,s0,/TWOD) ; initialisation de la structure geomat

NCDF_VARGET, id, NCDF_VARID(id,'NbLatitudes'), lat
NCDF_VARGET, id, NCDF_VARID(id,'NbLongitudes'), lon
IF (para EQ 'smo') THEN var_name='Grid_0001'
IF (para EQ 'err') THEN var_name='Grid_0002'
; lecture de la variable : smo ou erreur de la smo
NCDF_VARGET, id, NCDF_VARID(id,var_name), var
NCDF_ATTGET, id, NCDF_VARID(id,var_name), '_FillValue', flg
NCDF_CLOSE,  id  ; fermeture du fichier
var  = flag_matrix(TEMPORARY(var),seuil=flg)
var  = TRANSPOSE(TEMPORARY(var),[1,0]) ; on transpose la matrice pour avoir H[lon,lat]

geo.lon = lon
geo.lat = lat
geo.val = TEMPORARY(var)

IF KEYWORD_SET(verbose) THEN BEGIN
  print,'smo2geomat  : extraction du parametre  = ',para
  print,'smo2geomat  :          valeur du flag  = ',flg
ENDIF

RETURN, geo
END