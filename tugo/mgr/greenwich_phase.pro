FUNCTION greenwich_phase,phase,ut=ut,waves=waves,inverse=inverse,time_lag=time_lag
; return the greenwich phase from the local

; [125.,25.]        : give the phase or phase diff
; /INVERSE          : return the local phase from the greenwich
; ut=5.5            : give the time zone
; waves=['M2','S2'] : give the wave list
; /TIME_LAG         : return the time diff in hour and minute

IF NOT KEYWORD_SET(waves) THEN waves = 'M2'
IF NOT KEYWORD_SET(ut)    THEN ut   = 0.


;load the wave list nom/frequence/periode
wave_list=load_tidal_wave_list(/UPPERCASE,/QUIET)

FOR i=0,N_ELEMENTS(phase)-1 DO BEGIN
  wave_speed   = tidal_wave_info(waves[i],WAVE_LIST=wave_list)
  IF KEYWORD_SET(inverse) THEN BEGIN
     g       = phase[i]+ut*wave_speed
     gphase  = (360.+g) MOD 360. 
     PRINT,'wave = ',waves[i],' : G = ',phase[i],' ==> g = ',gphase
  ENDIF ELSE BEGIN
     g = phase[i]-ut*wave_speed
     gphase  = (360.+g) MOD 360. 
     IF KEYWORD_SET(time_lag) THEN BEGIN
       PRINT,'wave = ',waves[i],' : DG = ',phase[i],' => Dh = ',phase[i]/wave_speed,'h => Dmin = ',(phase[i]/wave_speed)*60.,'min'
     ENDIF ELSE BEGIN
       PRINT,'wave = ',waves[i],' : g = ',phase[i],' ==> G = ',gphase
     ENDELSE
 ENDELSE
ENDFOR
RETURN, gphase
END