FUNCTION fill_info_track, stx, sla=sla, detided=detided, absolute=absolute, scale=scale
; fait quelques calculs de base sur le points de la trace pour remplir les champs
; rms et trend de la strcuture stx
; par defaut renvoie la valeur SSH non corrigee (ni maree, ni effet meteo)
; /detited  : renvoie la SSH corrigee seulement de la maree 
; /sla      : renvoie la SSH corrigee de la maree et des effets meteos (dac)


IF NOT KEYWORD_SET(scale) THEN scale=100.

s    = SIZE(stx.pt.sla)
npt  = s[2]       ; nbre de point de la trace
ncyc = s[1]       ; nbre de cycle

FOR i=0,npt-1 DO BEGIN                                          ; pour chaque point de la trace 
 date   =  stx.pt[i].jul                                          ; date
 val    = (stx.pt[i].sla+stx.pt[i].tide+stx.pt[i].dac)*scale      ; SSH brute en cm (signal total)
 prefix = 'un'
 suffix = ' for tidal and met. effects'
 IF KEYWORD_SET(sla) THEN BEGIN
   prefix=''
   suffix=' for tidal and met. effects'
   val  =  stx.pt[i].sla*scale                                     ; SSH (corrige des effets meteo et maree, en cm)
 ENDIF
 IF KEYWORD_SET(detided) THEN BEGIN
   prefix=''
   suffix=' for tidal effects'
   val  =  (stx.pt[i].sla+stx.pt[i].dac)*scale                    ; SSH (corrige de la maree seulement, en cm)
 ENDIF
 stx.pt[i].rms  = STDDEV(val,/NAN)                                ; ecart-type en cm
 id   = WHERE(FINITE(val),count)
 IF (count GT 0) THEN r_coef=LINFIT(date[id],val[id],SIGMA=err) ELSE r_coef=LINFIT(date,val,SIGMA=err) 
 stx.pt[i].trend      = r_coef(1)*3650.                                       ; tendance en mm/an
 stx.info_rms   = 'RMS of SSH '+prefix+'corrected'+suffix
 stx.info_trend = 'TREND of SSH '+prefix+'corrected'+suffix+' in mm/year'
ENDFOR
RETURN, stx 
END