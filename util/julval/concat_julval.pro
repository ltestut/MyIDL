; $Id: concat_julval.pro,v 1.00 22/12/2004 L. Testuts $
;

;+
; NAME:
;	CONCAT_JULVAL
;
; PURPOSE:
;	Concatenate in one two structures of type {jul,val}
;	
; CATEGORY:
;	Util procedure/fucntion
;
; CALLING SEQUENCE:
;	st=CONCAT_JULVAL(struct1,struct2)
;	
;       use the fct/proc : -> TRI_JULVAL
;
; INPUTS:
;	struct  : structure of type {jul,val}
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
; Le 03/07/2009 ADD the possibility to concat the rms julval structure      
;-

FUNCTION concat_julval, st1, st2, nosort=nosort

N   = N_ELEMENTS(st1)+N_ELEMENTS(st2)
nt1 = N_TAGS(st1)    & nt2 = N_TAGS(st2) 
tn1 = TAG_NAMES(st1) & tn2 = TAG_NAMES(st2)

IF ((nt1 GT 2) AND (nt2 GT 2)) THEN BEGIN
   IF ((tn1[2] EQ 'RMS') AND (tn2[2] EQ 'RMS')) THEN BEGIN
     stf     = create_julval(N,/rms)
     stf.jul = [st1.jul,st2.jul]
     stf.val = [st1.val,st2.val]
     stf.rms = [st1.rms,st2.rms]
   ENDIF ELSE BEGIN
     stf     = create_julval(N)
     stf.jul = [st1.jul,st2.jul]
     stf.val = [st1.val,st2.val]
   ENDELSE
ENDIF ELSE BEGIN
   stf     = create_julval(N)
   stf.jul = [st1.jul,st2.jul]
   stf.val = [st1.val,st2.val]  
ENDELSE  

IF NOT KEYWORD_SET(nosort) THEN stf     = tri_julval(stf)
RETURN, finite_st(stf)

END
