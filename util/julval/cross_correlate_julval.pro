; $Id: cross_correlate_julval.pro,v 1.00 15/05/2007 L. Testut $
;

;+
; NAME:
;	cross_correlate_julval
;
; PURPOSE:
;	Compute the evolution of the linear correlation coefficient of 2 time series type {jul:0.0D, val:0.0} when lagged each other
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=cross_correlate_julval(st1,st2,range=range, units=units, step=step, /show, /usage)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> FINITE_ST
;                          -> SYNCHRO_JULVAL
; INPUTS:
;       st1     : Structure of type {jul:0.0D, val:0.0}
;       st2     : Structure of type {jul:0.0D, val:0.0}
;       range   : [Min,Max] of the lag
;       units   : Units of the lag between 'day','hour','mn'
;       step    : Step of the lag
;       /show   : Plot the figure of the correlation coef vs the lagged time
;       /usage  : Give the usage of the procedure/fucntion
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
; 
;-

FUNCTION  cross_correlate_julval, st1, st2, range=range, units=units, step=step, show=show, usage=usage, _EXTRA=_EXTRA
ON_ERROR,2
IF KEYWORD_SET(usage) THEN print, "USAGE: tab_correlation=cross_correlate_julval(st1,st2,range=[-10.,10.],units='mn',step=2, /show, /usage)"

IF (N_ELEMENTS(range) EQ 0) THEN range=[-1.,1.]
IF (N_ELEMENTS(units) EQ 0) THEN units='day'
IF (N_ELEMENTS(step) EQ 0) THEN step=1

N_LAG = FLOOR((range[1]-range[0])/step)+1
cor   = FLTARR(N_LAG)
res   = FLTARR(N_LAG)
x_lag = range[0]+INDGEN(N_LAG)*step

FOR I=0,N_LAG-1 DO BEGIN
IF (units eq 'day')  THEN cor[I]= correlate_julval(st1,st2,day=range[0]+I*step,res=resid,_EXTRA=_EXTRA)
IF (units eq 'hour') THEN cor[I]= correlate_julval(st1,st2,hour=range[0]+I*step,res=resid,_EXTRA=_EXTRA)
IF (units eq 'mn')   THEN cor[I]= correlate_julval(st1,st2,mn=range[0]+I*step,res=resid,_EXTRA=_EXTRA)
IF (units eq 'sec')  THEN cor[I]= correlate_julval(st1,st2,sec=range[0]+I*step,res=resid,_EXTRA=_EXTRA)
res[i]=resid
print,i,range[0]+I*step,'   cor = ',cor[I],'   res = ', res[I]
ENDFOR


IF KEYWORD_SET(show) THEN plot,x_lag,cor,ystyle=1,xstyle=1
index  = WHERE(cor EQ max(cor),count)
index2 = WHERE(res EQ min(res),count)
print,"Max of correlation when st2 is lagged of :",x_lag[index],"   ",units," Cor=",max(cor)
print,"Min of residuals   when st2 is lagged of :",x_lag[index2],"   ",units,"Res=",min(res)

RETURN, cor
END
