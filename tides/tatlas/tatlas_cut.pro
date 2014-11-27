FUNCTION tatlas_cut, atlas, quiet=quiet, _EXTRA=_EXTRA
; cut a tide atlas from given geo limit 

 ;info on the size of the input structures 
nwaves     = N_ELEMENTS(atlas.wave)
ntags      = N_TAGS(atlas)
ntags_wave = N_TAGS(atlas.wave)

 ;identify the cutting limits
a_limit = [MIN(atlas.lat),MIN(atlas.lon),MAX(atlas.lat),MAX(atlas.lon)] ;atlas original limit
glimit  = geo_limit(atlas,/QUIET,_EXTRA=_EXTRA)
IF (glimit[1] LT 0.) THEN glimit[1]=360.+glimit[1]  ; pour passer les longitudes en positifs.
IF (glimit[3] LT 0.) THEN glimit[3]=360.+glimit[3]  ; pour passer les longitudes en positifs.
icol = WHERE((atlas.lon GE glimit[1]) AND (atlas.lon LE glimit[3]),cpt_col)
irow = WHERE((atlas.lat GE glimit[0]) AND (atlas.lat LE glimit[2]),cpt_row)

atlas_out = create_tatlas(cpt_col,cpt_row,nwaves,/HUV) ;create the output structure
;copy new lon, lat and common fields 
atlas_out.lon = atlas.lon[icol]
atlas_out.lat = atlas.lat[irow]
tab_tags = WHERE(TAG_NAMES(atlas) NE 'LON' AND TAG_NAMES(atlas) NE 'LAT' AND TAG_NAMES(atlas) NE 'WAVE',cpt)
FOR i=0,cpt-1 DO atlas_out.(tab_tags[i]) = atlas.(tab_tags[i])

;on recopie les champs generaux (commun a toutes les ondes) 
atlas_out.wave.(0) = atlas.wave.(0) ;NAME
atlas_out.wave.(1) = atlas.wave.(1) ;FILENAME
FOR i=2,ntags_wave-1 DO atlas_out.wave.(i) = atlas.wave.(i)[icol,irow,0] 

IF NOT KEYWORD_SET(quiet) THEN BEGIN
glimit_out=geo_limit(atlas_out,/QUIET)
PRINT,'#####################  TATLAS_CUT  ##############################'
PRINT,FORMAT='(%"Input original atlas limits : %6.2fE / %6.2fE / %6.2fN / %6.2fN")',a_limit[1],a_limit[3],a_limit[0],a_limit[2]
PRINT,FORMAT='(%"Cutting limits              : %6.2fE / %6.2fE / %6.2fN / %6.2fN")',glimit[1],glimit[3],glimit[0],glimit[2]
PRINT,FORMAT='(%"Ouput atlas limits          : %6.2fE / %6.2fE / %6.2fN / %6.2fN")',glimit_out[1],glimit_out[3],glimit_out[0],glimit_out[2]
ENDIF


RETURN,atlas_out
END 
