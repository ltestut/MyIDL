; $Id: vazquez_filter.pro,v 2.00 2/02/2006 L. Testut $
;

;+
; NAME:
;	vazquez_filter
;
; PURPOSE:
;	
; CATEGORY:
;	Read/Write procedure/function
;
; CALLING SEQUENCE:
;	st=vazquez_filter(st,period,sampling=sampling,/plot)
;	
;       use      --> finite_st (function)
;                --> create_julval (function)
;                --> plot_julval (procedure)
; INPUTS:
;	st       : structure of type {jul,val}
;       period   : the period in days of the filter (defaults is set to 30 days)
;       sampling : the time step of the filtred time base (defaults is set to 1 day)
;       /plot    : plot the unfiltred and filtred data with steps of iteration
;
; OUTPUTS:
;	Structure {jul,val} with jul=date and val=filtered_values 
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
; - le 2/02/06 rebuild the routine from the original one (use matrix mutliplication)
;- 

; EXAMPLE 1:
; ---------


FUNCTION vazquez_filter, st, period, sampling=sampling, plot=plot, _EXTRA=_EXTRA
IF N_PARAMS() EQ 0 THEN BEGIN
    print,"Filtre les donnees de type julval"
    print,"USAGE: vazquez_filter, st, period, sampling=sampling, plot=plot, _EXTRA=_EXTRA"
    print,""
    print," (1) => stf=vazquez_filter(st,10,sampling=1) "
    print,"        renvoie une structure de type julval qui contient les valeurs filtree "
    print,"        de st > a 10 jours sur un echantillonnage de 1 jours                  "
    RETURN,""
ENDIF




IF (N_ELEMENTS(period)   EQ 0) THEN period=30   ; Set a default filter period of 30 days
IF (N_ELEMENTS(sampling) EQ 0) THEN sampling=1  ; Set a default sampling of 1 day
IF KEYWORD_SET(plot) THEN plot_julval,st,_EXTRA=_EXTRA


; Information on the time serie to filter (the input)
; --------------------------------------------------
st       = finite_st(st)          ; Remove all NaN of the unfiltered structure 
julmax   = MAX(st.jul,MIN=julmin) ; Date min and max of the unfiltered structure
N1       = N_ELEMENTS(st)         ; Number of elements of the daily mean structure 

; Information on the filtred time serie (the output)
; --------------------------------------------------
t       = TIMEGEN(START=ROUND(JULMIN),FINAL=ROUND(JULMAX),UNIT='Days',STEP_SIZE=sampling)
N2      = N_ELEMENTS(t)
stf     = create_julval(N2)
stf.jul = t
W       = DBLARR(N1,N2) 
H       = FLTARR(N2)

; Build a Matrix (N1xN2) where N1 the "unfiltred" time base 
; where N2 the vazquez filtred time base.
; each rows of the matrix represent en gaussian with sigma=period 
; ---------------------------------------------------------------
FOR J=0,N2-1 DO W[*,J]=EXP((-(t[J]-st[*].jul)^2)/(1.44*(period^2))) 
sum_rows=TOTAL(W,1,/NAN) ; Sum each of the rows in W

LOADCT,0
FOR K=0,20 DO BEGIN             
    HI = INTERPOL(stf.val,stf.jul,st.jul)   ; Y1=INTERPOL(Y0,X0,X1)
    stf.val  = TRANSPOSE(W##(st.val-HI))/sum_rows       
IF KEYWORD_SET(plot) THEN OPLOT,stf.jul,stf.val,color=255-K*16,thick=K*0.2
ENDFOR
RETURN, stf
END
