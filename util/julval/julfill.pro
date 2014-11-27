; $Id: julfill.pro,v 1.00 28/05/2008 L. Testut $
;

;+
; NAME:
;	JULFILL
;
; PURPOSE:
;	Fill a structure of type {jul:0.0D, val:0.0} between date tmin
;	and tmax or return 0 if there is no data in between tmin and tmax
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=JULFILL(st,tmin=tmin,tmax=tmax,dmin=dmin, dmax=dmax, verb=verb)
;
;       use the fct/proc : -> GET_FORMAT
;
; INPUTS:
;	st   : Structure of type {jul,val}
;	tmin : Inferior date limit in text format : 2803200512 (for 28/03/2005 at 12H)
;	tmax : Superior date limit in text format : 2803200512 (for 28/03/2005 at 12H)
;       dmin : Inferior date limit in julian days
;       dmax : Superior date limit in julian days
; val  : the value to fill by default NaN
;       verb : Verbose
;
; OUTPUTS:
;	Structure of type {jul,val}
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
; - Adaptation from julcut.pro
;-

FUNCTION  julfill, st, tmin=tmin, tmax=tmax, dmin=dmin, dmax=dmax, val=val, verb=verb

IF (N_PARAMS() EQ 0) THEN STOP, 'st=JULFILL(st,tmin=tmin,tmax=tmax,dmin=dmin,dmax=dmax,val=val,/verb)'
IF NOT KEYWORD_SET(val) THEN val=!VALUES.F_NAN
print,val
ERROR = 'Attention pas de dates limites'

; GESTION DE LA DATE
; ------------------
IF (N_ELEMENTS(dmin) EQ 0) THEN dmin = MIN(st.jul,/NAN)
IF (N_ELEMENTS(dmax) EQ 0) THEN dmax = MAX(st.jul,/NAN)
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
i=WHERE((st.jul GE dmin) AND (st.jul LE dmax),count)
IF (count GT 1) THEN st[i].val=val
IF KEYWORD_SET(verb) THEN print,'JULFILL =',print_date(dmin),'  ------->  ',print_date(dmax),count,' with ',val
RETURN, st
END
