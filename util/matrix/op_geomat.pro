FUNCTION op_geomat, geo, op=op,lon=lon,lat=lat,$
                        _EXTRA=_EXTRA
; compute some operation on a geomatrix
; if op='trend' must

; op='correlate' 
; lon : longitude of point for correlation
; lat : latitude  of point for correlation
; lag : 0 (defaut set to 0) 
; 
IF (N_TAGS(geo) GT 3) THEN BEGIN
  IF (op EQ 'fit') THEN BEGIN
    geot     = create_geomat(N_ELEMENTS(geo.lon),N_ELEMENTS(geo.lat),/TIDE)
    geot.amp = op_matrix(geo.val, OP=op, M2=geot.pha,_EXTRA=_EXTRA)
  ENDIF ELSE BEGIN
   geot      = create_geomat(N_ELEMENTS(geo.lon),N_ELEMENTS(geo.lat))
   CASE op OF
     'correlate' : BEGIN
                   st=geomat2julval(geo,LON=lon,LAT=lat)
                   geot.val = op_matrix(geo.val, op=op,s=st.val,_EXTRA=_EXTRA)
                   END
    ELSE : BEGIN
      geot.val = op_matrix(geo.val, op=op,_EXTRA=_EXTRA)
    END
   ENDCASE
  ENDELSE
  geot.lon = geo.lon
  geot.lat = geo.lat
  RETURN,geot
ENDIF ELSE BEGIN
  STOP,"NEED TIME DEPENDENCY (OR 3D GEOMAT)"
ENDELSE


END