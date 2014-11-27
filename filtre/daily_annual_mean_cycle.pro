PRO daily_annual_mean_cycle, st, stf

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'daily_annual_mean_cycle, st, stf'
 print, ''
 print, 'INPUT: st   --> str de type {jul,val}'
 print, 'OUTPUT: stf --> moyenne annuel des moyennes journalieres'
RETURN
ENDIF

CALDAT, st.jul, month, day, year
YMIN  = MIN(year[WHERE(FINITE(st.jul))],/NAN)
YMAX  = MAX(year[WHERE(FINITE(st.jul))],/NAN)
NY   = YMAX-YMIN+1
ND   = NY*12*31

tmp  = {jul:0.0D ,val:0.0}
stf  = REPLICATE(tmp,ND)
K    = 0

FOR I=YMIN,YMAX DO BEGIN    ;c BOUCLE SUR LES ANNEES
    FOR M=1,12 DO BEGIN     ;c BOUCLE SUR LES MOIS
        FOR D=1,31 DO BEGIN ;c BOUCLE SUR LES JOURS
	    stf[K].jul=JULDAY(M,D,I,0,0,0)
               ID=WHERE((month EQ M) AND (day EQ D),count)
               IF (count GE 1) THEN BEGIN
               stf[K].val=MEAN(st[ID].val,/NAN)
               ENDIF ELSE BEGIN
               stf[K].val=!VALUES.F_NAN
               ENDELSE
               K=K+1    	    
	       ENDFOR	    
      ENDFOR          
ENDFOR

;;Derniere modif le 13/05/2003
END
