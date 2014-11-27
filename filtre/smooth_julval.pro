; $Id: smooth_julval.pro, v 1.00 23/05/2007 L. Testut $
;
;+
; NAME:
;	smooth_julval
;
; PURPOSE:
;	Smooth a time serie of type {jul:0.0D, val:0.0}
;
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=smooth_julval(st,/usage)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> SAMPLING_JULVAL
;
; INPUTS:
;       st      : Structure of type {jul:0.0D, val:0.0} to be smoothed
;       /usage  : Give the usage of the procedure/fucntion
;
; OUTPUTS:
;	Structure of type {jul:0.0D, val:0.0} smoothed
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
FUNCTION smooth_julval,st,tsmooth=tsmooth,hf=hf, usage=usage,median=median, verbose=verbose,_EXTRA=_EXTRA
ON_ERROR,2
IF KEYWORD_SET(usage) THEN print,'USAGE: st=smooth_julval(st,tsmooth=2 *in hour*, /hf, /usage)'
tech = sampling_julval(st)/(60.*60.)                ;Sampling in hours
IF (N_ELEMENTS(tsmooth) EQ 0) THEN tsmooth=tech     ;No smoothing by default
N    = ROUND(tsmooth/tech)
stf  = create_julval(N_ELEMENTS(st.jul))

IF KEYWORD_SET(verbose) THEN BEGIN
   print,'Sampling of the time series    :',tech,' Hours'
   print,'Smoothing period               :',tsmooth,' Hours'
   print,'Number of point used to smooth :',N,' Points'
   ENDIF

IF (N_ELEMENTS(tsmooth) EQ 0) THEN N=1 ;No smoothing by default
stf.jul = st.jul
IF KEYWORD_SET(median) THEN stf.val = MEDIAN(st.val,N,_EXTRA=_EXTRA) ELSE stf.val = SMOOTH(st.val,N,/NAN,_EXTRA=_EXTRA)
IF KEYWORD_SET(hf) THEN stf.val=st.val-stf.val

RETURN,stf
END
