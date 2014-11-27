FUNCTION geo_limit, geo, limit=limit, zone=zone, quiet=quiet
; return geographical limits in IDL order [lonmin,lonmax,latmin,latmax]
IF (N_ELEMENTS(limit) EQ 0) THEN BEGIN
   g_limit=[min(geo.lat),min(geo.lon),max(geo.lat),max(geo.lon)] ;if no explicit limit keyword 
ENDIF ELSE BEGIN
   g_limit=[limit[2],limit[0],limit[3],limit[1]]                 ;if limit is provided
ENDELSE
IF KEYWORD_SET(zone) THEN g_limit=use_zone(zone)                 ;user defined limit 
IF NOT KEYWORD_SET(quiet) THEN BEGIN
 PRINT,"--------------------- [GEO_LIMIT] ------------------------------"
 PRINT,FORMAT='(%"Query geographic limit : %6.2fE / %6.2fE / %6.2fE / %6.2fE")',$
               g_limit[1],g_limit[3],g_limit[0],g_limit[2]
 PRINT,"----------------------------------------------------------------"
ENDIF
RETURN,g_limit

;old_version
;; renvoie les limites de la geomatrice dans l'ordre utilise pour CONTOUR
;; lim=geo_limit(geo)                          renvoie par defaut les limites de la matrice
;; lim=geo_limit(geo,limit=[-180,180,-89,89])  renvoie les limites utilisateurs
;; lim=geo_limit(geo,zone='spa')               renvoie les limites par mot-cle (cf. use_zone)
;
;IF (N_ELEMENTS(limit) EQ 0) THEN BEGIN
;    g_limit=[min(geo.lat),min(geo.lon),max(geo.lat),max(geo.lon)] ;par defaut si pas de mot-cle
;ENDIF ELSE BEGIN
;   g_limit=[limit[2],limit[0],limit[3],limit[1]]                 ;limites definie par l'utilisateur [lon_min,lon_max,lat_min,lat_max]
;ENDELSE
;IF KEYWORD_SET(zone) THEN g_limit=use_zone(zone)            ;limite definie par une zone 
;IF NOT KEYWORD_SET(quiet) THEN BEGIN
; PRINT,'#####################  GEO_LIMIT  ##############################'
; PRINT,FORMAT='(%"Query geographic limit  : %6.2fE / %6.2fE / %6.2fE / %6.2fE")',g_limit[1],g_limit[3],g_limit[0],g_limit[2]
;ENDIF
;RETURN,g_limit
END