FUNCTION  n_between_julval, st, tmin=tmin, tmax=tmax, dmin=dmin, dmax=dmax, verb=verb

IF (N_PARAMS() EQ 0) THEN STOP, 'st=n_between_julval(st,tmin=tmin,tmax=tmax,dmin=dmin,dmax=dmax,/verb)'

ERROR = 'Attention pas de dates limites'

; GESTION DE LA DATE
; ------------------
IF (N_ELEMENTS(dmin) EQ 0) THEN dmin = MIN(st.jul,/NAN)
IF (N_ELEMENTS(dmax) EQ 0) THEN dmax = MAX(st.jul,/NAN)
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
i=WHERE((st.jul GE dmin) AND (st.jul LE dmax),count)
IF KEYWORD_SET(verb) THEN print,'N between =  ',print_date(dmin,/s),' AND ',print_date(dmax,/s),' = ',count
RETURN, count
END
