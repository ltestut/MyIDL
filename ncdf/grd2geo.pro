FUNCTION grd2geo, filename, xscan=xscan
; lecture d'un fichier .grd (GMT) 
id   = NCDF_OPEN(filename)

IF KEYWORD_SET(xscan) THEN BEGIN
 ;recupere les valeurs limites des variables x,y,z
NCDF_VARGET,id,NCDF_VARID(id,'x_range'),x_range
NCDF_VARGET,id,NCDF_VARID(id,'y_range'),y_range
NCDF_VARGET,id,NCDF_VARID(id,'z_range'),z_range
NCDF_VARGET,id,NCDF_VARID(id,'spacing'),spacing
 ;calcul du nbr de points et des vecteurs lon, lat
nx  = FLOOR(ABS(x_range[1]-x_range[0])/spacing[0]+1,/L64)
ny  = FLOOR(ABS(y_range[1]-y_range[0])/spacing[1]+1,/L64)
lon = x_range[0]+INDGEN(nx)*spacing[0]
lat = y_range[0]+INDGEN(ny)*spacing[1]
 ;recuperation de la variable z  
NCDF_VARGET,id,NCDF_VARID(id,'z'),val
h = REVERSE(REFORM(val,nx,ny),2,/OVERWRITE)
ENDIF ELSE BEGIN
 ;recupere les valeurs limites des variables x,y,z
NCDF_VARGET,id,NCDF_VARID(id,'x'),x
NCDF_VARGET,id,NCDF_VARID(id,'y'),y
NCDF_VARGET,id,NCDF_VARID(id,'z'),h
 ;calcul du nbr de points et des vecteurs lon, lat
nx  = N_ELEMENTS(x)
ny  = N_ELEMENTS(y)
lon = x
lat = y
; ;recuperation de la variable z  
;NCDF_VARGET,id,NCDF_VARID(id,'z'),val
;h = REVERSE(REFORM(val,nx,ny),2,/OVERWRITE)
ENDELSE

;creation d'une structure de type geomat
 geo     = create_geomat(nx,ny) ; initialisation de la structure geomat geo(lon,lat,time)
 geo.lon = lon
 geo.lat = lat
 geo.val = h

RETURN,geo
END