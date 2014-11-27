; $Id: add_julval.pro,v 1.00 26/05/2005 L. Testut $
;

;+
; NAME:
;	ADD_JULVAL
;
; PURPOSE:
;	Add a number to the .val of a structure of type {jul:0.0D, val:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=ADD_JULVAL(st,x)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> FINITE_ST
; INPUTS:
;       st  : Structure of type {jul:0.0D, val:0.0}
;	x   : The value to add
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

FUNCTION  add_julval, st, add=add , mul=mul,  mean=mean

IF (N_PARAMS() EQ 0) THEN STOP, 'st=ADD_JULVAL(st,x,/mean)'
st  = FINITE_ST(st)

st1 = CREATE_JULVAL(N_ELEMENTS(st.jul))
st1.jul=st.jul
st1.val=st.val+FLOAT(x)
RETURN, st1
END
