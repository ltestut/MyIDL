; $Id: tri_julval.pro,v 1.00 22/12/2004 L. Testut $
;

;+
; NAME:
;	TRI_JULVAL
;
; PURPOSE:
;	Sort a structure of type {jul,val} 
;	
; CATEGORY:
;	Util procedure/fucntion
;
; CALLING SEQUENCE:
;	st=TRI_JULVAL(struct)
;	
;       use the fct/proc : -> SORT
;
; INPUTS:
;	Struct     : structure of type {jul,val}
;
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
;       Modification of the procedure tri_jul_val (2003)
; Le 03/07/2009 ADD the possibility to concat the rms julval structure
;-

FUNCTION tri_julval, st
nt  = N_TAGS(st)
tn  = TAG_NAMES(st)
ITS = SORT(st.jul)

IF (nt EQ 2) THEN BEGIN
   st.jul = st[ITS].jul
   st.val = st[ITS].val
ENDIF

IF (nt GT 2) THEN BEGIN
   IF (tn[2] EQ 'RMS') THEN BEGIN
      st.jul = st[ITS].jul
      st.val = st[ITS].val
      st.rms = st[ITS].rms
   ENDIF ELSE BEGIN
      st.jul = st[ITS].jul
      st.val = st[ITS].val
   ENDELSE
ENDIF  

RETURN, st
END
