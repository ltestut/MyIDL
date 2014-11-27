; $Id: sync2julval.pro,v 1.00 15/05/2005 L. Testut $
;

;+
; NAME:
;	SYNC2JULVAL
;
; PURPOSE:
;	Transform the output of the synchro_data Procedure in two
;	structure of type julval
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	SYNC2JULVAL,sync,st1,st2
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;	sync : Structure of type .juln .y1, .lag
;
; OUTPUTS:
;	st1  : Structure of type {jul,val}
;	st2  : Structure of type {jul,val}
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

PRO sync2julval, sync, st1, st2

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  sync2julval, sync, st1, st2 '

st1=CREATE_JULVAL(N_ELEMENTS(sync.jul))
st2=CREATE_JULVAL(N_ELEMENTS(sync.jul))

st1.jul=sync.jul
st2.jul=sync.jul

st1.val=sync.y1
st2.val=sync.y2

print,'Creation de 2 structures julval'
END
