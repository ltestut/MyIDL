; $Id: flag_julval.pro,v 1.00 14/05/2009 L. Testut $
;

;+
; NAME:
; FLAG_JULVAL
;
; PURPOSE:
; flag a structure of type {jul:0.0D, val:0.0} between date tmin
; and tmax or return 0 if there is no data in between tmin and tmax
; 
; CATEGORY:
; utile procedure/fucntion
;
; CALLING SEQUENCE:
; st=FLAG_JULVAL(st,tmin=tmin,tmax=tmax,dmin=dmin, dmax=dmax, verb=verb)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> GET_FORMAT
;
; INPUTS:
; st   : Structure of type {jul,val}
; tmin : Inferior date limit in text format : 2803200512 (for 28/03/2005 at 12H)
; tmax : Superior date limit in text format : 2803200512 (for 28/03/2005 at 12H)
;       dmin : Inferior date limit in julian days
;       dmax : Superior date limit in julian days
;       verb : Verbose
;
; OUTPUTS:
; Structure of type {jul,val}
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;-

FUNCTION  flag_julval, st, tmin=tmin, tmax=tmax, dmin=dmin, dmax=dmax, verb=verb

IF (N_PARAMS() EQ 0) THEN STOP, 'st=JULCUT(st,tmin=tmin,tmax=tmax,dmin=dmin,dmax=dmax,/verb)'

ERROR = 'Attention pas de dates limites'

; GESTION DU NBRE DE TAGS
; -----------------------
;st  = finite_st(st) ;/!\ pourquoi j'avais mis ca ??
st1 = st
nt  = N_TAGS(st)
tn  = TAG_NAMES(st)

; GESTION DE LA DATE
; ------------------
IF (N_ELEMENTS(dmin) EQ 0) THEN dmin = MIN(st.jul,/NAN)
IF (N_ELEMENTS(dmax) EQ 0) THEN dmax = MAX(st.jul,/NAN)
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
i=WHERE((st.jul GE dmin-0.00001) AND (st.jul LE dmax+0.00001),count)
IF KEYWORD_SET(verb) THEN print,'FLAG_JULVAL =',print_date(dmin,/single),'  ------->  ',print_date(dmax,/single),count

IF (count GE 1) THEN BEGIN
 IF (nt EQ 2 ) THEN BEGIN 
  st1[i].val = !VALUES.F_NAN 
 ENDIF
 IF (nt GT 2) THEN BEGIN
   IF (tn[2] EQ 'RMS') THEN BEGIN
   st1[i].val = !VALUES.F_NAN
   st1[i].rms = !VALUES.F_NAN
   ENDIF
 ENDIF
ENDIF
RETURN, st1
END
