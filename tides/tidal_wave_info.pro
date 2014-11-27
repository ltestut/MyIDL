FUNCTION tidal_wave_info, wave, wave_list=wave_list, period=period
; return  information regarding the wave period and speed
;   defaut    : wave speed in deg/heure
;   /period   : period in hours

 ;number of input waves
nwa = N_ELEMENTS(wave) 

IF (nwa GT 1) THEN BEGIN
  id  = INTARR(nwa)
  val = FLTARR(nwa)
  FOR i=0,nwa-1 DO BEGIN
     id[i] = WHERE(tidal_replace_name(STRUPCASE(wave[i])) EQ wave_list.name, cpt)
     IF (cpt EQ 1) THEN BEGIN
        val[i] = wave_list[id[i]].speed1
        IF KEYWORD_SET(period) THEN val[i] = wave_list[id[i]].period1   
     ENDIF ELSE BEGIN
        STOP,'No wave with this name found '+wave[i]
     ENDELSE
  ENDFOR
ENDIF ELSE BEGIN
  id = WHERE(wave[0] EQ wave_list.name, cpt)
  IF (cpt EQ 1) THEN BEGIN
    val = wave_list[id].speed1
    IF KEYWORD_SET(period) THEN val = wave_list[id].period1   
  ENDIF ELSE BEGIN
    STOP,'No wave with this name found '+wave
  ENDELSE
ENDELSE

RETURN, val
END
