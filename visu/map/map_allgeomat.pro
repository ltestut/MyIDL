PRO map_allgeomat, geo, _EXTRA=_EXTRA

; Trace une GEOMAT quelque soit le type (tide or not tide ...)


s = SIZE(geo.val)

IF ( s[0] EQ 0 ) THEN BEGIN
  map_tgeomat, geo, _EXTRA=_EXTRA
ENDIF ELSE BEGIN
  map_geomat, geo, _EXTRA=_EXTRA
ENDELSE



END