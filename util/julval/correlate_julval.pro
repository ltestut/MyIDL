; $Id: correlate_julval.pro,v 1.00 15/05/2007 L. Testut $
;

;+
; NAME:
;	correlate_julval
;
; PURPOSE:
;	Compute the linear Pearson correlation coefficient of 2 time series type {jul:0.0D, val:0.0}
;       The second time series can be lagged 
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=correlate_julval(st1,st2,day=day,hour=hour,mn=mn,/show)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> FINITE_ST
;                          -> SYNCHRO_JULVAL
; INPUTS:
;       st1     : Structure of type {jul:0.0D, val:0.0}
;       st2     : Structure of type {jul:0.0D, val:0.0}
;       hour    : Number of hours of the lag
;       day     : Number of days of the lag
;       mn      : Number of minutes of the lag
;       /show   : plot the time series on an X window
;
; OUTPUTS:
;	The correlation coefficient
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
; - Le 01/01/2009 Add the /verb Keyword 
;-

FUNCTION  correlate_julval, st1, st2, day=day, hour=hour, mn=mn, sec=sec, show=show, res=res, _EXTRA=_EXTRA

IF (N_PARAMS() EQ 0) THEN STOP, 'st=correlate_julval(st1,st2,day=day, hour=hour, mn=mn, /show)'
IF (N_ELEMENTS(day) EQ 0) THEN day=0.
IF (N_ELEMENTS(hour) EQ 0) THEN hour=0.
IF (N_ELEMENTS(mn) EQ 0) THEN mn=0.
IF (N_ELEMENTS(sec) EQ 0) THEN sec=0.

st1     = FINITE_ST(st1)
st2     = FINITE_ST(st2)

;The second time serie is lagged of a certain amount of time if necessary
;st2c is a copy of st2 to preserve the original st2
IF KEYWORD_SET(verb) THEN BEGIN
print,FORMAT='(A28,I4,A4,I4,A4,I4,A4,I4,A4)',"Decalage de la serie 2 de : ",day,"j / ",hour,"h / ",mn,"mn / ",sec,"s / "
ENDIF
st2c = lag_julval(st2,day=day,hour=hour,mn=mn,sec=sec)

;The 2 series are synchronized on the same common time basis
synchro_julval, st1, st2c, stsync1,stsync2, _EXTRA=_EXTRA, /verb

IF KEYWORD_SET(show) THEN plot_julval, stsync1, stsync2

cor = CORRELATE(stsync1.val,stsync2.val)
res = STDDEV(stsync1.val-stsync2.val)
RETURN, cor
END
