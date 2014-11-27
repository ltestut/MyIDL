FUNCTION diff_geouv, geo1,geo2, verbose=verbose, _EXTRA=_EXTRA
; calcul la difference de 2 geomat de type UV  
; retourne une structure de type geomat contenant la difference

; pas d'interpolation dans un premier temps
;
;geo_interpolate, geo1, geo2, geo1_interp, geo2_interp, verbose=verbose

nx=N_ELEMENTS(geo1.lon)
ny=N_ELEMENTS(geo1.lat)
 
geodiff     =create_geomat(nx, ny, /UV)
geodiff.lon = geo1.lon
geodiff.lat = geo1.lat
geodiff.u   = geo1.u - geo2.u
geodiff.v   = geo1.v - geo2.v
geodiff.info = geo1.info+'  :  '+geo2.info
geodiff.filename = FILE_BASENAME(geo1.filename)+' - '+FILE_BASENAME(geo2.filename)
 
  
RETURN, geodiff
END