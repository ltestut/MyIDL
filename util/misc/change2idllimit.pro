FUNCTION change2idllimit, limit, reverse=reverse
; function qui convertit du format [lonmin,lonmax,latmin,latmax] au format [latmin,lonmin,latmax,lonmax] utiliser par les routine IDL
;IF (limit[0] GT 350) THEN limit[0]=limit[0]-360.
;IF (limit[1] GT 350) THEN limit[1]=limit[1]-360.
idl_limit=[limit[2],limit[0],limit[3],limit[1]]
IF KEYWORD_SET(reverse) THEN idl_limit=[limit[1],limit[3],limit[0],limit[2]]
RETURN, idl_limit
END