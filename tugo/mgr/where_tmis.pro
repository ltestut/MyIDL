FUNCTION  where_tmis, tmis_in, id=id, wave=wave
; extract a sub tmis from index or wave vector
; id    : extract a tmis for these id only
; wave  : extract a tmis for these waves

IF (N_PARAMS() EQ 0) THEN STOP, 'st=WHERE_TMIS(tmis,id=id,wave=wave)'

 ;parameters of input structure
tmis       = tmis_in
nsta       = N_ELEMENTS(tmis.sta)
nwave      = N_ELEMENTS(tmis.sta[0].wave)
ntag_tmis  = N_TAGS(tmis)
ntag_sta   = N_TAGS(tmis.sta)
ntag_wave  = N_TAGS(tmis.sta.wave)

IF KEYWORD_SET(id) THEN BEGIN
 tmis1  = create_tmisfit(N_ELEMENTS(id),nwave,/NAN)       ;new tmis reduced to the selected id
 FOR i=0,ntag_tmis-2 DO tmis1.(i)=tmis.(i)                ;general information filling
 FOR j=0,ntag_sta-2  DO tmis1.sta.(j)=tmis.sta[id].(j)    ;station information filling
 FOR k=0,ntag_wave-1 DO tmis1.sta.wave.(k)=tmis.sta[id].wave.(k) ;wave value filling
 ;parameters of input structure
tmis       = tmis1
nsta       = N_ELEMENTS(tmis.sta)
nwave      = N_ELEMENTS(tmis.sta[0].wave)
ntag_tmis  = N_TAGS(tmis)
ntag_sta   = N_TAGS(tmis.sta)
ntag_wave  = N_TAGS(tmis.sta.wave)
ENDIF

IF KEYWORD_SET(wave) THEN BEGIN
 nwa    = N_ELEMENTS(wave)                    ;number of selected waves
 idw    = INTARR(nwa)                         ;vector of selected waves indexes  
 tmis1  = create_tmisfit(nsta,nwa,/NAN)       ;new tmis reduced to the selected waves
 FOR ig=0,ntag_tmis-2 DO tmis1.(ig)=tmis.(ig) ;general information filling
 FOR j=0,ntag_sta-2 DO tmis1.sta.(j)=tmis.sta.(j)                       ;station information filling
 FOR i=0,nsta-1 DO BEGIN                                                       ;loop on all station
        FOR k=0,nwa-1 DO idw[k] = WHERE(tmis.sta[i].wave.name EQ wave[k],cpt)  ;build selected wave indexes vector
        inan=WHERE(idw LE 0,COMPLEMENT=ival,cpt)                               ;missing selected wave 
        IF (cpt GE 1) THEN BEGIN
         FOR l=0,ntag_wave-1 DO tmis1.sta[i].wave[ival].(l)=tmis.sta[i].wave[idw[ival]].(l) ;wave value filling
         FOR l=0,ntag_wave-1 DO tmis1.sta[i].wave[inan].(l)=!VALUES.F_NAN                   ;Nan  value filling
        ENDIF ELSE BEGIN
         FOR l=0,ntag_wave-1 DO tmis1.sta[i].wave.(l)=tmis.sta[i].wave[idw].(l) ;wave value filling
        ENDELSE
 ENDFOR
ENDIF

RETURN, tmis1
END