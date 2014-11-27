; $Id: ah_coef.pro,v 1.00 23/05/2005 L. Testut $
;

;+
; NAME:
;	AH_COEF
;
; PURPOSE:
;	Compute the Harmonic Analysis of a {jul,val} structure and
;	return the coefficients
;  
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	coef=AH_COEF(st,/ond77)
;	
;       use the fct/proc : -> CREATE_JULVAL
;                          -> CURVEFIT
;                         
; INPUTS:
;	st    : Structure of type {jul,val}
;
; OUTPUTS:
;	coef  : Array of the AH coefficient to be used with ah_predi
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
;

FUNCTION ah_coef, st, ond77=ond77

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  coef=ah_coef(st,/ond77)'

NA   = 2        & IF KEYWORD_SET(ond77) THEN NA=77
funct= 'tides2' & IF KEYWORD_SET(ond77) THEN funct='tides77'
IT   = WHERE(FINITE(st.val),count)
w    = MAKE_ARRAY(count, VALUE=1.)
A    = MAKE_ARRAY(NA*2,VALUE=10.)
fit  = CURVEFIT(st[IT].jul,(st[IT].val-MEAN(st[IT].val,/NAN)),w,A,FUNCTION_NAME=funct)

st1=CREATE_JULVAL(count)
st1.jul=st[IT].jul
st1.val=fit

;RETURN, A
RETURN, st1

END
