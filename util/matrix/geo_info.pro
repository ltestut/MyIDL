PRO geo_info,geo
; print information on geomatrice

gtype=geo_type(geo)
help,geo,/STRUCTURES
glimit=geo_limit(geo,_EXTRA=_EXTRA)
IF FIX(TOTAL(TAG_NAMES(geo) EQ 'JUL')) EQ 1 THEN $
     p=print_date(geo.jul[[0,N_ELEMENTS(geo.jul)-1]])
END