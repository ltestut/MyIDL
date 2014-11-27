FUNCTION create_stx, npt, ncy, nan=nan
; create a stx type structure with *npt* points and *ncy* cycles

tmp  = {lon:0.0,   lat:0.0, mssh:0.0, bathy:0.0, d2coast:0.0D, valid:0.0, $
        rms:0.0, trend:0.0,  cor:0.0,                $
        jul:DBLARR(ncy),  sla:MAKE_ARRAY(ncy,/FLOAT,VALUE=!VALUES.F_NAN),$
                          tide:MAKE_ARRAY(ncy,/FLOAT,VALUE=!VALUES.F_NAN),$
                           dac:MAKE_ARRAY(ncy,/FLOAT,VALUE=!VALUES.F_NAN)}
                         
IF KEYWORD_SET(nan) THEN BEGIN
 tmp  = {lon:!VALUES.F_NAN, lat:!VALUES.F_NAN, mssh:0.0, bathy:0.0, d2coast:0.0D, $
        rms:0.0, trend:0.0,  cor:0.0,                $
        jul:DBLARR(ncy),  sla:MAKE_ARRAY(ncy,/FLOAT,VALUE=!VALUES.F_NAN),$
                          tide:MAKE_ARRAY(ncy,/FLOAT,VALUE=!VALUES.F_NAN),$
                           dac:MAKE_ARRAY(ncy,/FLOAT,VALUE=!VALUES.F_NAN)}
ENDIF

;- on replique la structure pour les npt
stx  = replicate(tmp,npt)


 ;on ajoute les variables informatives de la structure
stx = {info:'', name:'', filename:'', pass:'', cycle:INTARR(ncy),$
       info_rms:'', info_trend:'', info_cor:'',$   
       pt:stx} 

RETURN, stx
END