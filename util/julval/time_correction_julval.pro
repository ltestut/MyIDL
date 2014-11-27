; $Id: time_correction_julval.pro,v 1.00 29/05/2007 L. Testut $
;
;+
; NAME:
;	TIME_CORRECTION_JULVAL
;
; PURPOSE:
;	Allows to correct the julval structure for a linear clock drift
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=TIME_CORRECTION_JULVAL(st,drift=drift)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;	st      : Structure de be corrected
;       drift=  : Drift in minutes/day
;
; OUTPUTS:
;	Structure of type {jul,val} corrected from the drift
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
FUNCTION time_correction_julval, st, drift=drift
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=TIME_CORRECTION_JULVAL(st,drift=*in sec/day*)'
IF (N_ELEMENTS(drift) EQ 0) THEN drift=0.
print,"Application d'une correction de derive de :",drift,"  s/jour" 
tmin=MIN(st.jul,max=tmax,/NAN)

stc     = create_julval(N_ELEMENTS(st.jul))
tc      = drift/(24.*3600.)*(st.jul-tmin)
stc.jul = st.jul+tc
stc.val = st.val
RETURN, stc
END
