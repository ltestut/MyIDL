FUNCTION cut_tmis, tmis, limit=limit, quiet=quiet
; decoupe un tmis a partir des coordonnees geographiques

IF NOT KEYWORD_SET(limit) THEN BEGIN
 ;determination des min/max des coordonnees geographique
 limit    = get_tmis_limit(tmis)
ENDIF
IF NOT KEYWORD_SET(quiet) THEN print,'Decoupe le matrice selon :[',limit[0],'/',limit[1],'/',limit[2],'/',limit[3],']'

id = WHERE(tmis.sta.lat GT limit[2] AND $
           tmis.sta.lat LT limit[3] AND $
           tmis.sta.lon GT limit[0] AND $
           tmis.sta.lon LT limit[1],count)

IF (count GE 1) THEN BEGIN
 tmis_out=where_tmis(tmis,id=id)
 RETURN,tmis_out
ENDIF ELSE BEGIN
 PRINT, 'No DATA in tmis'
 RETURN, -1
ENDELSE
END 