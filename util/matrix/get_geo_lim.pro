
; $Id: get_geo_lim.pro,v 1.00 03/2010 C. MAYET $

;+
; NAME:
; GET_GEO_LIM
;
; PURPOSE:
; get the geographical limits of a geomat structure
; 
; CATEGORY:
; geomat
;
; CALLING SEQUENCE:
; lim=get_geo_lim(geomat)
;
; INPUTS:
;       geomat  : Structure of type {geo.lon, geo.vlat, geo.val, geo.jul, geo.amp, geo.pha}
;
; OUTPUTS:
; float array [lonmin, lonmax, latmin, latmax]
;
; MODIFICATION HISTORY:

;-


FUNCTION get_geo_lim, geo, quiet=quiet
minlon   = MIN(geo.lon, /NaN, MAX=maxlon)
minlat   = MIN(geo.lat, /NaN, MAX=maxlat)
limites  = [minlon,maxlon,minlat,maxlat]
IF NOT KEYWORD_SET(quiet) THEN BEGIN
 PRINT,'#####################  GET_GEO_LIMIT  ##############################'
 PRINT,FORMAT='(%"Limit of the geomatrix  : %6.2fE / %6.2fE / %6.2fN / %6.2fN")',minlon,maxlon,minlat,maxlat
ENDIF


return, limites

END