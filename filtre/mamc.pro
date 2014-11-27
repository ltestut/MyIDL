; $Id: mamc.pro,v 1.00 6/06/2005 L. Testut $
;

;+
; NAME:
;	MAMC
;
; PURPOSE:
;	Compute from a {jul,val} structure the monthly annual mean, ie
;	the mean of each month over the whole serie
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=mamc(st,rms=rms,num=num)
;	
;       use      --> create_julval (function)
;
; INPUTS:
;	Structure of type {jul,val}
;
; OUTPUTS:
;	Structure of type {jul,val} which contains:
;                 - the mean for each month
;        if /num  - the number of value used to compute the mean 
;        if /rms  - the rms for each month
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
; - 22/05/2008 Add the monthly keyword for monthly input structure
;
;- 

FUNCTION mamc, st, monthly=monthly, rms=rms, num=num

IF (N_PARAMS() EQ 0) THEN print, 'UTILISATION:st=mamc(st,/monthly,/num,/rms)'

stm=st
IF NOT KEYWORD_SET(monthly) THEN stm = monthly_mean(stm)

CALDAT, stm.jul, month, day, year
YMIN  = MIN(year[WHERE(FINITE(stm.jul))],/NAN)
YMAX  = MAX(year[WHERE(FINITE(stm.jul))],/NAN)
NY    = YMAX-YMIN+1
ND    = NY*12

stmam = CREATE_JULVAL(ND)
strms = CREATE_JULVAL(ND)
stnum = CREATE_JULVAL(ND)
K     = 0

FOR I=YMIN,YMAX DO BEGIN        ;c BOUCLE SUR LES ANNEES
    FOR M=1,12 DO BEGIN         ;c BOUCLE SUR LES MOIS
        stmam[K].jul = JULDAY(M,15,I,0,0,0)
        strms[K].jul = JULDAY(M,15,I,0,0,0)
        stnum[K].jul = JULDAY(M,15,I,0,0,0)
        ID           = WHERE((month EQ M),count)
        IF (count GE 1) THEN BEGIN
            stmam[K].val  =  MEAN(stm[ID].val,/NAN)
            strms[K].val  =  STDDEV(stm[ID].val,/NAN)
            stnum[K].val  =  count
        ENDIF ELSE BEGIN
            stmam[K].val  =  !VALUES.F_NAN
            strms[K].val  =  !VALUES.F_NAN
            stnum[K].val  =  !VALUES.F_NAN
        ENDELSE
        K=K+1    	    
    ENDFOR	    
;print,I,'->  K=',K,count,'  Mean,rms,num',stmam[K-1].val, strms[K-1].val,stnum[K-1].val
ENDFOR

IF KEYWORD_SET(num) THEN RETURN, stnum
IF KEYWORD_SET(rms) THEN RETURN, strms
RETURN, stmam

END
