FUNCTION build_synthetic_tidal_julval, amp=amp , periode=periode, phase=phase, jmin=jmin,jmax=jmax, noise=noise, ech=ech
IF NOT KEYWORD_SET(jmin)      THEN jmin=JULDAY(1,1,2002)
IF NOT KEYWORD_SET(jmax)      THEN jmax=jmin+365.
IF NOT KEYWORD_SET(ech) THEN ech=5

wave_list=load_tidal_wave_list(/UPPERCASE,/QUIET)


; Construction de la base de temps
; --------------------------------
time   = TIMEGEN(start=jmin,final=jmax,unit='minutes', step_size=ech)
Nt     = N_ELEMENTS(time)                                                                              ; nbre de valeurs de la série
st     = create_julval(Nt)
st.jul = time
; Construction du signal de reference
; -----------------------------------
MSL = 0.
dpi = 2.*!PI
IF NOT KEYWORD_SET(amp)     THEN amp     = [100. ,50.,20.    ,24.    ,10.    ,5.     ,4.      ,2.   ] ;amplitude en cm 
IF NOT KEYWORD_SET(amp)     THEN amp     = [100. ,50.,20.    ,24.    ,10.    ,5.     ,4.      ,2.   ] ;amplitude en cm 
IF NOT KEYWORD_SET(periode) THEN periode = [12.421,12.,12.6576,23.9352,11.9664,25.8192,12.8712,26.868] ;periode en heures [8 ondes]
  
; 'K1','O1','Q1']
; 23.9352,25.8192,26.868
 
n_wave = N_ELEMENTS(amp)
frq    = 1./(periode/24.)       ;frequences associees
y      = FLTARR(Nt)
FOR I=0,n_wave-1 DO BEGIN
y = y + amp[I]*cos(dpi*frq[I]*(time-jmin))
END

; Ajout d'un bruit à la serie
; ---------------------------
no = 5.*RANDOMU(0,N_ELEMENTS(time))
IF KEYWORD_SET(noise) THEN y=y+no

st.val = y
RETURN,st
END
