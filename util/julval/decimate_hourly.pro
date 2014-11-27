; $Id: decimate_hourly.pro,v 1.00 11/07/2008 L. Testut $
;

;+
; NAME:
;	DECIMATE_HOURLY
;
; PURPOSE:
;	Decimate a hf {jul,val} time serie into hourly data
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	std=decimate_hourly(st,/verb)
;
;       use the fct/proc : -> TIMEGEN
;                          -> FINITE_ST
;                          -> SYNCHRO_JULVAL
;                          -> WHERE
; INPUTS:
;	st     : Structure of type {jul,val}
;
; OUTPUTS:
;	std   : Structure of type {jul,val} hourly value
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;-
;

FUNCTION decimate_hourly, st_in, bs=bs, _EXTRA=_EXTRA, verbose=verbose
IF (N_PARAMS() EQ 0) THEN STOP, "st=decimate_hourly(st,/verb)"
st     = finite_st(st_in)
nt     = N_TAGS(st)     ; number of tag
tn     = TAG_NAMES(st)  ; name of tags

jmin       = FLOOR(MIN(st.jul))-0.5
jmax       = FLOOR(MAX(st.jul))+0.5
binsize    = 1.  ; 1hr binsize
IF NOT KEYWORD_SET(bs) THEN bs=30. 
; On decoupe chaque serie en tranche de 1H et on verifie la presence de valeurs
;print,print_date(jmin) & print,print_date(jmax)
base_temps  = TIMEGEN(start=jmin,final=jmax,unit='hours', step_size=1) ;on creer une base de temps horaire
IF (nt EQ 2 ) THEN st_base = create_julval(N_ELEMENTS(base_temps))
IF (nt GT 2) THEN BEGIN
   IF (tn[2] EQ 'RMS') THEN BEGIN
   st_base     = create_rms_julval(N_ELEMENTS(base_temps))
   st_base.rms = !VALUES.F_NAN
   ENDIF
ENDIF
st_base.jul = base_temps
st_base.val = 1.
synchro_julval, st_in, st_base, sti$b, stb$i, bs=bs, /VERBOSE
RETURN, sti$b
END
