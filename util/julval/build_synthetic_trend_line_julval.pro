FUNCTION build_synthetic_trend_line_julval, trend=trend , jmin=jmin,jmax=jmax, ech=ech, offset=offset
;fonction qui va construire une droite de regression entre deux dates
; st.val = trend[mm/yr]*(st[N].jul-st[0].jul) + st[0].val
; ech  : echantillonnage de la serie en mois
; 

IF NOT KEYWORD_SET(jmin)    THEN jmin=JULDAY(1,1,2002)
IF NOT KEYWORD_SET(jmax)    THEN jmax=jmin+365.
IF NOT KEYWORD_SET(ech)     THEN ech=1
IF (N_ELEMENTS(trend) EQ 0) THEN trend=1   ;en mm/yr 
IF NOT KEYWORD_SET(offset)  THEN offset=0. ;en cm 

 ;construction de la base de temps
time      = TIMEGEN(start=jmin,final=jmax,unit='months', step_size=ech)
Nt        = N_ELEMENTS(time)                                                                              ; nbre de valeurs de la série
st        = create_julval(Nt)
st.jul    = time
st[0].val = offset                  ;en cm
 ;construction de la droite de regression
st.val = trend*((st.jul-time[0])/(365.*10.))+offset
RETURN,st
END
