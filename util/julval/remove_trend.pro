; $Id: remove_trend.pro,v 1.00 08/06/2006 L. Testut $
;

;+
; NAME:
;	REMOVE_TREND
;
; PURPOSE:
;	Remove the linear trend to the .val of a structure of type {jul:0.0D, val:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=REMOVE_TREND(st)
;
;       use the fct/proc : -> CREATE_APPROPIATE_JULVAL
;                          -> FINITE_ST
; INPUTS:
;       st     : Structure of type {jul:0.0D, val:0.0} or {jul,val,rms}
;
; OUTPUTS:
;	Structure of type {jul,val} or {jul,val,rms}
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
; - Le 15/07/2008 add the mean to keep the mean of the values  
; - Le 15/07/08 add the possibility to pass {jul,val,rms} structure 
; - Le 23/04/09 modify the way to remove the trend (we remove the trend from the initial time t0 to the end) the mean is not conserved as previously 
; - Le 21/08/09 add the keep_mean keyword ton conserve the same mean 

;-

FUNCTION  remove_trend, st, keep_mean=keep_mean

IF (N_PARAMS() EQ 0) THEN STOP, 'st=REMOVE_TREND(st)'
st     = FINITE_ST(st)
st1    = create_appropriate_julval(st)
r_coef = LINFIT(st.jul,st.val,SIGMA=err,yfit=yfit)
st1.jul= st.jul
IF KEYWORD_SET(keep_mean) THEN BEGIN 
   st1.val=(st.val-yfit)+MEAN(st.val,/NAN) ;ancienne methode ou on garde la valeur moyenne
ENDIF ELSE BEGIN
   st1.val= st.val-r_coef[1]*(st.jul-st[0].jul) ;on applique Y=Y-b(t-t0) on considere que la derive commence au temps t0
ENDELSE

RETURN, st1
END
