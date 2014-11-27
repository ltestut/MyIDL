; $Id: fill_nan_julval.pro, v 1.00 06/07/2009 L. Testut ... a Manaus !! $
;
;+
; NAME:
;	fill_nan_julval
;
; PURPOSE:
;	Fill the gap in a time serie of type {jul:0.0D, val:0.0} with NaN
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=fill_nan_julval(st,/verb)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> SAMPLING_JULVAL
;
; INPUTS:
;       st      : Structure of type {jul:0.0D, val:0.0} to be filled
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
;
;-
FUNCTION fill_nan_julval,st,samp=samp, verbose=verbose

IF NOT KEYWORD_SET(samp) THEN samp = sampling_julval(st) ;sampling of the time serie in seconds 

 ;remove the NaN
stc=finite_st(st)
 ;compute the new time base
time_base = TIMEGEN(START = MIN(st.jul,/NAN), FINAL = MAX(st.jul,/NAN) , UNIT  = 'Seconds', STEP=samp)
stn       = create_julval(N_ELEMENTS(time_base),/NAN)      ;on creer un structure avec des NaN partout
stn.jul   = time_base

synchro_julval,stc,stn,stc$n,stn$c,id1,id2,/WITH_NAN, bs=samp, verbose=verbose
stn[id2].val=stc[id1].val ;on replace les dates communes par les valeur de la serie 1
RETURN,stn
END

