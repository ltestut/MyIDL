; $Id: add_trend.pro,v 1.00 28/06/2005 L. Testut $
;

;+
; NAME:
;	ADD_TREND
;
; PURPOSE:
;	Add a linear trend to the .val of a structure of type {jul:0.0D, val:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=ADD_TREND(st,coef=coef,t0=t0)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> FINITE_ST
; INPUTS:
;       st     : Structure of type {jul:0.0D, val:0.0}
;	Coef   : Coefficient of the trend to add in xx/days
;	(st.val=st.val+coef*(T-T0))
;       T0     : Initial value of time
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
; 
;-

FUNCTION  add_trend, st, coef=coef , t0=t0

IF (N_PARAMS() EQ 0) THEN STOP, 'st=ADD_TREND(st,coef=coef,T0=T0)'
IF NOT KEYWORD_SET(t0) THEN STOP, 'Need initial value'
st  = FINITE_ST(st)

st1 = CREATE_JULVAL(N_ELEMENTS(st.jul))
st1.jul=st.jul
st1.val=st.val+coef*(st.jul-t0)
RETURN, st1
END
