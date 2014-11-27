FUNCTION cut_mgr, mgr, limit=limit, quiet=quiet
;cut a mgr inside limit

IF NOT KEYWORD_SET(limit) THEN limit=get_mgr_limit(mgr)
IF NOT KEYWORD_SET(quiet) THEN $
 PRINT,FORMAT='(%" Geographic limit = %7.3f°E /%7.3f°E /%7.3f°N /%7.3f°N")',$
 limit[0],limit[1],limit[2],limit[3]

id = WHERE(mgr.lat GT limit[2] AND $
           mgr.lat LT limit[3] AND $
           mgr.lon GT limit[0] AND $
           mgr.lon LT limit[1],count)

IF (count GE 1) THEN BEGIN
 mgr_out=where_mgr(mgr,id)
 RETURN,mgr_out
ENDIF ELSE BEGIN
 PRINT, 'No DATA in mgr'
 RETURN, -1
ENDELSE
END 