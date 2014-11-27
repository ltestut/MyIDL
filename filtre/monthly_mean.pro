; $Id: monthly_mean.pro,v 1.00 7/07/2005 L. Testut $
;

;+
; NAME:
;	MONTHLY_MEAN
;
; PURPOSE:
;	Compute from a {jul,val} structure the monthly mean
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=monthly_mean(st,num=num)
;
;       use      --> create_julval (function)
;
; INPUTS:
;	Structure of type {jul,val}
;
; OUTPUTS:
;	Structure of type {jul,val,rms} which contains:
;                 - the mean for each month and the std deviation
;        if /num  - the number of value used to compute the mean
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
; - Le 23/11/2006 add the NMIN criterium keyword
; - Le 12/07/2008 change the {jul,val} output structure to {jul,val,rms} 
; - Le 20/01/2009 add the year_eff to compute only non void year 
; - Le 21/01/2009 replace the nmin keyword by a percent keyword. 

;-


FUNCTION monthly_mean, st, num=num, percent=percent, nmin=nmin, verbose=verbose

IF (N_PARAMS() EQ 0) THEN print, 'UTILISATION:st=monthly_mean(st,/num,percent=80)'
IF NOT KEYWORD_SET(percent) THEN percent=50.
N_full = (30.*24.*3600.)/sampling_julval(st)  ; nombre de valeur necessaire pour un mois entier de 30 jours
IF NOT KEYWORD_SET(nmin) THEN nmin   = ROUND(percent*N_full/100.)           ; nombre de valeur min utilisees pour la calul de la moy

IF KEYWORD_SET(verbose) THEN BEGIN
   print,FORMAT='(A33,X,I7,X,A14,I4,X,A2)',"Moy calculee avec un minimum de :",nmin,"data/mois soit [",nmin*100./N_full,"%]"
ENDIF

CALDAT, st.jul, month, day, year
YMIN      = MIN(year[WHERE(FINITE(st.jul))],/NAN)
YMAX      = MAX(year[WHERE(FINITE(st.jul))],/NAN)
year_eff  = remove_doublon_tab(year)  ;annees effectives
NY        = N_ELEMENTS(year_eff)      ;nbre d'annees effective
ND        = NY*12
stf       = create_rms_julval(ND) 
stc       = create_julval(ND)
K         = 0

FOR I=0,Ny-1 DO BEGIN        ;c BOUCLE SUR LES ANNEES
    Y_void = 0                  ;compteur presence de valeur par annee
    FOR M=1,12 DO BEGIN         ;c BOUCLE SUR LES MOIS
    stf[K].jul=JULDAY(M,15,year_eff[I],0,0,0)
    stc[K].jul=JULDAY(M,15,year_eff[I],0,0,0)
    ID=WHERE((year EQ year_eff[I]) AND (month EQ M),count)
    Y_void += count
        IF (count GE NMIN) THEN BEGIN
            stf[K].val=MEAN(st[ID].val,/NAN)
            stf[K].rms=STDDEV(st[ID].val,/NAN)
            stc[K].val=count
        ENDIF ELSE BEGIN
            stf[K].val=!VALUES.F_NAN
            stf[K].rms=!VALUES.F_NAN
            stc[K].val=0.
        ENDELSE
    K=K+1
    ENDFOR
ENDFOR
IF KEYWORD_SET(num) THEN RETURN, stc
RETURN, finite_st(stf)
END
