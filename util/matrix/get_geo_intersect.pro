
; $Id: get_geo_intersect.pro,v 1.00 03/2010 C. MAYET $
;+
; NAME:
; GET_GEO_INTERSECT
;
; PURPOSE:
; get the intersection of two geographical domains
; 
; CATEGORY:
; geo
;
; CALLING SEQUENCE:
; geo_intersect=get_geo_intersect(lim1,lim2)
;
; INPUTS:
;      limit1  : float array [lonmin, lonmax, latmin, latmax] 
;      limit2  : float array [lonmin, lonmax, latmin, latmax]
; OUTPUTS:
;       geo_intersect  :  float_array [lonmin, lonmax, latmin, latmax] 
;

FUNCTION get_geo_intersect, limites1, limites2

geo_intersect=[(limites1[0]>limites2[0]),(limites1[1]<limites2[1]),(limites1[2]>limites2[2]),(limites1[3]<limites2[3])]

return, geo_intersect

END