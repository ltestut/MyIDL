; $Id: replicate_julval.pro,v 1.00 29/09/2008 L. Testut $
;

;+
; NAME:
;	REPLICATE_JULVAL
;
; PURPOSE:
;	Replicate a structure of type {jul:0.0D, val:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=REPLICATE_JULVAL(st)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;	st   a {jul,val} structure to be replicated
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

FUNCTION  replicate_julval, st

N    = N_ELEMENTS(st)
st1  = create_julval(N)
st1.jul = st.jul
st1.val = st.val

RETURN, st1
END
