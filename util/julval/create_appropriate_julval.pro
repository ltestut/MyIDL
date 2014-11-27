; $Id: create_appropriate_julval.pro,v 1.00 11/11/2008 L. Testut $
;
;+
; NAME:
; CREATE_APPROPRIATE_JULVAL
;
; PURPOSE:
; Create a structure of type {jul:0.0D, val:0.0} or {jul:0.0D, val:0.0, rms:0.0} 
; 
; CATEGORY:
; utile procedure/fucntion
;
; CALLING SEQUENCE:
; st=CREATE_APPROPRAOTE_JULVAL(N)
;
;       use the fct/proc : -> REPLICATE
;                          -> CREATE_JULVAL
;                          -> CREATE_RMS_JULVAL
;
; INPUTS:
; N   : Number of replication of the structure definition
;
; OUTPUTS:
; Structure of type {jul,val} or {jul,val,rms} 
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
;
;-

FUNCTION create_appropriate_julval, st
nt     = N_TAGS(st)     ; number of tag
tn     = TAG_NAMES(st)  ; name of tags

IF (nt EQ 2 ) THEN st1 = create_julval(N_ELEMENTS(st))
IF (nt GT 2) THEN BEGIN
   IF (tn[2] EQ 'RMS') THEN BEGIN
   st1 = create_rms_julval(N_ELEMENTS(st))
   st1.rms= st.rms
   ENDIF
ENDIF
RETURN, st1
END