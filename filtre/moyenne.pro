PRO moyenne, st, sta, stm, std

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'moyenne, st,sta,stm,std'
 print, ''
 print, 'INPUT: st   --> str de type {jul,val}'
 print, 'OUTPUT: sta --> moyenne annuelle'
 print, 'OUTPUT: stm --> moyenne mensuelle'
 print, 'OUTPUT: std --> moyenne journaliere'
RETURN
ENDIF

CALDAT, st.jul, month, day, year
YMIN  = MIN(year[WHERE(FINITE(st.jul))],/NAN)
YMAX  = MAX(year[WHERE(FINITE(st.jul))],/NAN)
NY    = YMAX-YMIN+1
NM    = NY*12
ND    = NM*31

tmp  = {jul:0.0D ,val:0.0}
sta  = REPLICATE(tmp,NY)
stm  = REPLICATE(tmp,NM)
std  = REPLICATE(tmp,ND)


KY=0
KM=0
KD=0

FOR I=YMIN,YMAX DO BEGIN ;c BOUCLE SUR LES ANNEES
sta[KY].jul=JULDAY(1,1,I,0,0,0) ;c MOYENNE DATE AU 1er JANV de l'ANNEE EN COURS
    sta[KY].val=MEAN(st[WHERE(year EQ I)].val,/NAN)
    KY=KY+1

       FOR M=1,12 DO BEGIN ;c BOUCLE SUR LES MOIS
       stm[KM].jul=JULDAY(M,15,I,0,0,0) ;c MOYENNE DATE AU 15 DU MOIS EN COURS
            IM=WHERE((year EQ I) AND (month EQ M),count)
            IF (count GE 1) THEN BEGIN
            stm[KM].val=MEAN(st[IM].val,/NAN)
            ENDIF ELSE BEGIN
            stm[KM].val=!VALUES.F_NAN
            ENDELSE
            KM=KM+1    
	    
            FOR D=1,31 DO BEGIN ;c BOUCLE SUR LES JOURS
	    std[KD].jul=JULDAY(M,D,I,0,0,0)
               ID=WHERE((year EQ I) AND (month EQ M) AND (day EQ D),count)
               IF (count GE 1) THEN BEGIN
               std[KD].val=MEAN(st[ID].val,/NAN)
               ENDIF ELSE BEGIN
               std[KD].val=!VALUES.F_NAN
               ENDELSE
               KD=KD+1    	    
	       ENDFOR	    
      ENDFOR
          
ENDFOR

;;Derniere modif le 14/05/2003
END
