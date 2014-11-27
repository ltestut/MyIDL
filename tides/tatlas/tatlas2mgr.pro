FUNCTION tatlas2mgr, tatlas_in, mgr_in, wave_list=wave_list,$
                             scale=scale, $
                             _EXTRA=_EXTRA
; return a model mgr from a given mgr and a tidal atlas 
;   mgr_in      : input mgr        
;   tatlas_in   : input tidal atlas
;   wave_list   : ['M2','S2'] wave on which the mgr should be extract 
;                 (default all atlases waves)
;   scale       : to scale the amplitude of the output mgr

IF NOT KEYWORD_SET(scale) THEN scale=1.         ;by default should be in meter
IF NOT KEYWORD_SET(wave_list) THEN wave_list=tatlas_in.wave.name;def full wlist
 ;resize tatlas and mgr to match together (done twice to resize both )
tatlas=tatlas_mgr_domain_intersection(tatlas_in,mgr_in,MGR_OUT=mgr)  

 ;get the number and indexes of unique station
nwave    = N_ELEMENTS(wave_list)
cname    = cmset_op(mgr.name,'AND',mgr.name,COUNT=nsta,/KEEP_ORDER) ;nsta of common station /!\ beware of /KEEP_ORDER issue
mindex   = cmset_op(mgr.name,'AND',mgr.name,/INDEX,/KEEP_ORDER)     ;cindex index of common station
lon      = mgr[mindex].lon
lat      = mgr[mindex].lat
info     = cname[mindex]

PRINT,'#############recherche sur les stations :',cname, '#####################'
tab_val=tatlas2val(tatlas,LON=lon,LAT=lat,INFO=info,$
        WAVE=wave_list,IFINITE=ifinite,_EXTRA=_EXTRA)

 ;create the model mgr from the valid interpolation 
s        = SIZE(tab_val,/DIMENSIONS)
mgr_mod  = create_mgr(s[1],nwave)
mgr_mod.name     = cname[ifinite]
mgr_mod.origine  = tatlas.info
mgr_mod.enr      = 'Dfrom '+tatlas.info+' atlas' ;attention cette ligne doit commencer par D??? (comme les mgr de mrg : Debut ...)
mgr_mod.val      = 'no'                          ;c'est pour le tri des chaines de caracteres dans la lecture du read_mgr
mgr_mod.lat      = lat[ifinite]
mgr_mod.lon      = lon[ifinite]
mgr_mod.nwav     = nwave
mgr_mod.filename = ''   
FOR i=0,nwave-1 DO BEGIN
  PRINT,"Traitement de l'onde :",wave_list[i]
   mgr_mod.code[i]  = wave2code(wave_list[i])
   mgr_mod.wave[i]  = wave_list[i]         ;on remplit les nwa premieres ondes
   mgr_mod.amp[i]   = TRANSPOSE(tab_val[0,*,i])*scale
   mgr_mod.pha[i]   = TRANSPOSE(tab_val[1,*,i])
ENDFOR

PRINT,FORMAT='(%"tatlas2mgr  : interpolation of %3d stations (%3d failed) ")',s[1],N_ELEMENTS(lon)-s[1]

RETURN,mgr_mod
END