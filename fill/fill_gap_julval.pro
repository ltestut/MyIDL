; $Id: fill_gap_julval.pro, v 1.00 21/05/2007 L. Testut $
;
;+
; NAME:
;	fill_gap_julval
;
; PURPOSE:
;	Linearly interpolates a time serie of type {jul:0.0D, val:0.0} on a reference time series of type {jul:0.0D, val:0.0}
;       with the same sampling interval as the input structure or a given one. The program build a regular reference time serie based on the sampling interval as the input structure
;       and interpolated the input serie on this reference time serie.
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=fill_gap_julval(st,ech=ech,/verb)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> SAMPLING_JULVAL
;
; INPUTS:
;       st      : Structure of type {jul:0.0D, val:0.0} to be filled
;       ech     : Sampling period in minute
;
; OUTPUTS:
;	Structure of type {jul:0.0D, val:0.0} interpolated
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
; -Le 11/06/2007 Add the ech parameter
;
;-
FUNCTION fill_gap_julval,st,ech=ech,verb=verb
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN BEGIN
 print, "USAGE:'
 print, "st=fill_gap_julval(st      , *input {jul,val} structure*  "
 print, "                   ech=30. , *sampling period in minute"
 print, "                  /verb     *to get info on the filtering process"
STOP
ENDIF

;Mean sampling of the time serie in minutes
IF (N_ELEMENTS(ech) EQ 0) THEN ech = sampling_julval(st)/(60.) 

;Remove the NaN
stc=finite_st(st)

;Compute the new time base
time_base=TIMEGEN(START = min(st.jul,/NAN), FINAL = max(st.jul,/NAN) , UNIT  = 'Minutes', STEP=ech)

sti=create_julval(N_ELEMENTS(time_base))

sti.jul = time_base
sti.val = INTERPOL(stc.val,stc.jul,sti.jul)

RETURN,sti
END

