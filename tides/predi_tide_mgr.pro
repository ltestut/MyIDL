FUNCTION predi_tide_mgr, mgr, wave=wave, tmin=tmin, tmax=tmax, msl=msl
; prediction of the tides from a mgr structure
;  waves     = ['M2','S2']        : give the list of waves you want to use for prediction

IF NOT KEYWORD_SET(msl) THEN msl=0.
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))

wave_atlas  = load_tidal_wave_list(/UPPERCASE)               ;load tidal wave list (Name/frequence/period)

IF KEYWORD_SET(wave) THEN wlist  = wave ELSE wlist  = sort_wlist(mgr.wave,mgr)
nwav  = N_ELEMENTS(wlist)


time   = TIMEGEN(start=dmin,final=dmax,unit='hours',step_size=1)
st     = create_julval(N_ELEMENTS(time))
st.jul = time
st.val = msl

FOR i=0,nwav-1 DO BEGIN
  ik=WHERE(mgr.wave EQ wlist[i]       , cpt)
  iw=WHERE(wave_atlas.name EQ wlist[i], cpt2)
  IF (cpt EQ 1 AND cpt2 EQ 1) THEN BEGIN
    st.val = st.val + mgr.amp[ik[0]]*COS(rad(wave_atlas[iw].speed1*((st.jul-st[0].jul)*24.)-mgr.pha[ik[0]]))
  ENDIF
ENDFOR

RETURN,st
END