FUNCTION geomat2julval, geo, lon=lon, lat=lat, limit=limit
; extract a {jul,val} structure from a geomat either on 
; - location  : 
;  lon :lon
;  lat : lat
; - zone    :
; limit=[lon_min,lon_max,lat_min,lat_max]
s      = SIZE(geo.val)
Ntime  = s[3]
st     = create_julval(Ntime)    ;create st
st.jul = geo.jul                 ;get time value

IF KEYWORD_SET(limit) THEN BEGIN
  ; mean field whitihn the limit for each time step
  geoc   = geo_cut(geo,LIMIT=limit) 
  FOR I=0,Ntime-1 DO st[I].val = MEAN(geoc.val[*,*,I],/NAN)
ENDIF ELSE BEGIN
  ; time serie at given (lon,lat) for each time step
  FOR I=0,Ntime-1 DO st[I].val = BILINEAR(geo.val[*,*,I],$
                    igeo(geo.lon,lon),igeo(geo.lat,lat),MISSING=!VALUES.F_NAN)
ENDELSE
RETURN, st
END