PRO tatlas_obc_interpol, tatlas_in, st, wave_list=wave_list, scale=scale,$
                         output=output, node_index=node_index,_EXTRA=_EXTRA
; write a ascii file for boundary condition interpolated from a tidal atlas
;   tatlas_in   : input tidal atlas
;   st          : structutre {st.lon, st.lat} where data should be interpolated
;   LIMIT=[]    : to resize the tatlas
;   wave_list   : ['M2','S2'] wave on which the mgr should be extract (default all atlases waves)
;   scale       : to scale the amplitude of the output mgr
  
IF NOT KEYWORD_SET(scale) THEN scale=1.  ;by default should be in meter
IF NOT KEYWORD_SET(wave_list) THEN wave_list=tatlas_in.wave.name 
IF NOT KEYWORD_SET(output) THEN output=!txt

nwave    = N_ELEMENTS(wave_list)
tatlas   = tatlas_cut(tatlas_in,_EXTRA=_EXTRA)  ;resize tatlas 
tab_val  = tatlas2val(tatlas,LON=st.lon,LAT=st.lat,INFO=info,$
                                 WAVE=wave_list,IFINITE=ifinite,_EXTRA=_EXTRA)
fmt_out  = '(F7.4,X,F7.4,X,'+STRCOMPRESS(STRING(nwave),/REMOVE_ALL)+$
               '(F6.2,1X),'+STRCOMPRESS(STRING(nwave),/REMOVE_ALL)+'(F6.2,1X))'
fmt_head = '(A-7 ,X,A-7 ,X,'+STRCOMPRESS(STRING(nwave),/REMOVE_ALL)+$
                 '(A-6,1X),'+STRCOMPRESS(STRING(nwave),/REMOVE_ALL)+'(A-6,1X))'
  
 ; create the model mgr from the valid interpolation
s        = SIZE(tab_val,/DIMENSIONS)

OPENW,  UNIT, output  , /GET_LUN        ;; ouverture en ecriture du fichier
PRINTF, UNIT, "model  = "+tatlas.info
PRINTF, UNIT, "format = "+fmt_out
PRINTF, UNIT, "unit   = meter*"+STRING(scale)
PRINTF, UNIT, FORMAT=fmt_head,'Lon','Lat','amp_'+wave_list,'pha_'+wave_list
FOR i=0,N_ELEMENTS(ifinite)-1 DO BEGIN
 PRINTF, UNIT, FORMAT=fmt_out,st[i].lon,st[i].lat,TRANSPOSE(tab_val[0,i,*])*scale,TRANSPOSE(tab_val[1,i,*])
  ;FOR j=0,nwave-1 DO PRINTF,UNIT,tab_val[0,i,j]*scale,tab_val[1,i,j]
ENDFOR
CLOSE, UNIT
;FOR i=0,nwave-1 DO BEGIN
;    PRINT,"Traitement de l'onde :",wave_list[i]
;    mgr_mod.wave[i]  = wave_list[i]         ;on remplit les nwa premieres ondes
;    mgr_mod.amp[i]   = TRANSPOSE(tab_val[0,*,i])*scale
;    mgr_mod.pha[i]   = TRANSPOSE(tab_val[1,*,i])
;ENDFOR
;  
;  PRINT,FORMAT='(%"tatlas2mgr  : interpolation of %3d stations (%3d failed) ")',s[1],N_ELEMENTS(lon)-s[1]
  
END