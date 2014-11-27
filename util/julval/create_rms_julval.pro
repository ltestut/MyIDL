; $Id: create_rms_julval.pro,v 1.00 06/06/2008 L. Testut $
;

;+
; NAME:
;	CREATE_RMS_JULVAL
;
; PURPOSE:
;	Create a structure of type {jul:0.0D, val:0.0, rms:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=CREATE_RMS_JULVAL(N)
;
;       use the fct/proc : -> REPLICATE
;
; INPUTS:
;	N   : Number of replication of the structure definition
;
; OUTPUTS:
;	Structure of type {jul,val,rms}
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

FUNCTION  create_rms_julval, N

IF (N LT 1) THEN STOP, '!! ERROR in CREATE_RMS_JULVAL : N must be greater than 0'

; OBSOLETE UTILISE create_julval !!!

tmp = {jul:0.0D, val:0.0, rms:0.0}
st  = replicate(tmp,N)

RETURN, st
END
