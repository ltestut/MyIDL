; $Id: julcut.pro,v 1.00 26/05/2005 L. Testut $
;

;+
; NAME:
;	JULCUT
;
; PURPOSE:
;	Cut a structure of type {jul:0.0D, val:0.0} between date tmin
;	and tmax or return 0 if there is no data in between tmin and tmax
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=JULCUT(st,tmin=tmin,tmax=tmax,dmin=dmin, dmax=dmax, verb=verb)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> GET_FORMAT
;
; INPUTS:
;	st   : Structure of type {jul,val}
;	tmin : Inferior date limit in text format : 2803200512 (for 28/03/2005 at 12H)
;	tmax : Superior date limit in text format : 2803200512 (for 28/03/2005 at 12H)
;       dmin : Inferior date limit in julian days
;       dmax : Superior date limit in julian days
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
; - Le 07/06/2005 Add the dmin, dmax input parameter and /verb
; - Le 08/10/2007 Add the 0 output when no data are present between the time interval
; - Le 12/11/2007 Simplify the routine by using the get_format function
; - Le 01/08/08 add the possibility to pass {jul,val,rms} structure 
;-

FUNCTION  julcut, st, tmin=tmin, tmax=tmax, dmin=dmin, dmax=dmax, verb=verb

IF (N_PARAMS() EQ 0) THEN STOP, 'st=JULCUT(st,tmin=tmin,tmax=tmax,dmin=dmin,dmax=dmax,/verb)'

ERROR = 'Attention pas de dates limites'

; GESTION DU NBRE DE TAGS
; -----------------------
st = finite_st(st)
nt = N_TAGS(st)
tn = TAG_NAMES(st)

; GESTION DE LA DATE
; ------------------
IF (N_ELEMENTS(dmin) EQ 0) THEN dmin = MIN(st.jul,/NAN)
IF (N_ELEMENTS(dmax) EQ 0) THEN dmax = MAX(st.jul,/NAN)
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
i=WHERE((st.jul GE dmin-0.00001) AND (st.jul LE dmax+0.00001),count)
IF KEYWORD_SET(verb) THEN print,'JULCUT =',print_date(dmin,/single),'  ------->  ',print_date(dmax,/single),count

IF (nt EQ 2 ) THEN st1 = create_julval(count)

IF (nt GT 2) THEN BEGIN
   IF (tn[2] EQ 'RMS') THEN BEGIN
   st1 = create_rms_julval(count)
   st1.rms= st[i].rms
   ENDIF
ENDIF

st1.jul=st[i].jul
st1.val=st[i].val
RETURN, st1
END
