; $Id: where_julval.pro,v 1.00 05/12/2006 L. Testut $
;

;+
; NAME:
;	WHERE_JULVAL
;
; PURPOSE:
;	Select specific points on a julval structure.
;     a previous WHERE is needed to select the index points
;
; CATEGORY:
;	utile procedure/function
;
; CALLING SEQUENCE:
;	st=WHERE_JULVAL(st,iz)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;       st    : Structure of type {jul:0.0D, val:0.0}
;	  iz      : The result of a WHERE
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

FUNCTION  where_julval, st, iz
IF (N_PARAMS() EQ 0) THEN STOP, 'st=WHERE_JULVAL(st,iz)'
IF (N_ELEMENTS(iz) EQ 0)  THEN STOP, 'Need the index of the points iz'
; GESTION DU NBRE DE TAGS
; -----------------------
st1 = create_julval(N_ELEMENTS(iz),/RMS)
nt  = N_TAGS(st)
tn  = TAG_NAMES(st)

st1.jul = st[iz].jul
st1.val = st[iz].val

IF (nt GT 2) THEN BEGIN
   IF (tn[2] EQ 'RMS') THEN BEGIN
   st1[iz].rms = st[iz].rms
   ENDIF
ENDIF
RETURN, st1
END
