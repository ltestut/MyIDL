FUNCTION cut_track, stx, limit=limit, zone=zone
; coupe une region de la trace /limit
; ---------------------------

IF KEYWORD_SET(zone) THEN BEGIN
limit=zone_track(zone)
id = where(stx.pt.lat GT limit[0] AND $
           stx.pt.lat LT limit[2] AND $
           stx.pt.lon GT limit[1] AND $
           stx.pt.lon LT limit[3],count)
ENDIF ELSE BEGIN
id = where(stx.pt.lat GT limit[2] AND $
           stx.pt.lat LT limit[3] AND $
           stx.pt.lon GT limit[0] AND $
	         stx.pt.lon LT limit[1],count)
ENDELSE
stx_cut=select_track(stx,id)

RETURN, stx_cut 
END
