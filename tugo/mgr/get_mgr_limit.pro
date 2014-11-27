FUNCTION get_mgr_limit,mgr,verbose=verbose
;return geographic limit of a mgr
minlon   = MIN(mgr.lon, /NaN, MAX=maxlon)
minlat   = MIN(mgr.lat, /NaN, MAX=maxlat)
limit    = [minlon,maxlon,minlat,maxlat]
IF KEYWORD_SET(verbose) THEN $
 PRINT,FORMAT='(%" Geographic limit = %7.3f°E /%7.3f°E /%7.3f°N /%7.3f°N")',$
 minlon,maxlon,minlat,maxlat
RETURN, limit
END