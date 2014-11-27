; $Id: annual_mean.pro,v 1.00 11/07/2008 L. Testut $
;

;+
; NAME:
; ANNUAL_MEAN
;
; PURPOSE:
; Compute from a {jul,val} structure the annual mean
;
; CATEGORY:
; Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
; st=annual_mean(st,num=num)
;
;       use      --> create_julval (function)
;
; INPUTS:
; Structure of type {jul,val}
;
; OUTPUTS:
; Structure of type {jul,val,rms} which contains:
;                 - the mean for each month and the std deviation
;        if /num  - the number of value used to compute the mean
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;-

FUNCTION annual_mean, st, num=num, nmin=nmin

IF (N_PARAMS() EQ 0) THEN print, 'UTILISATION:st=annual_mean(st,/num,nmin=nmin)'
IF NOT KEYWORD_SET(nmin) THEN nmin=30  ;c Nombre minimum de donnnees par mois pour le calcul
CALDAT, st.jul, month, day, year
YMIN  = MIN(year[WHERE(FINITE(st.jul))],/NAN)
YMAX  = MAX(year[WHERE(FINITE(st.jul))],/NAN)
NY    = YMAX-YMIN+1
ND    = NY*12
stf   = create_rms_julval(NY) 
stc   = create_julval(NY)
K     = 0

print,"Calcul de la moyenne annuel pour un minimum de ",NMIN," donnees par an"

FOR I=YMIN,YMAX DO BEGIN    ;c BOUCLE SUR LES ANNEES
	    stf[K].jul=JULDAY(6,15,I,0,0,0)
      stc[K].jul=JULDAY(6,15,I,0,0,0)
               ID=WHERE((year EQ I),count)
               IF (count GE NMIN) THEN BEGIN
               stf[K].val=MEAN(st[ID].val,/NAN)
               stf[K].rms=STDDEV(st[ID].val,/NAN)
               stc[K].val=count
               ENDIF ELSE BEGIN
               stf[K].val= !VALUES.F_NAN
               stf[K].rms= !VALUES.F_NAN
               stc[K].val= !VALUES.F_NAN
               ENDELSE
               K=K+1    	    
ENDFOR
IF KEYWORD_SET(num) THEN RETURN, stc
RETURN, stf
END
