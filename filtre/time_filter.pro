PRO time_filter, st, Tmin, Tmax, stf

IF (N_PARAMS() EQ 0) THEN BEGIN
print, 'UTILISATION:
print, 'time_filter, st,Tmin,Tmax,stf'
print, 'Ce filtre est uniquement pour des donnees echantillonnees regulierement'
print, 'INPUT: st,Tmin(J),Tmax(J)'
print, 'OUTPUT: stf'
RETURN
ENDIF

N     = N_ELEMENTS(st)
it    = WHERE(FINITE(st.val,/NAN),count)
I     = 0
ECHXI = (st[I+1].jul-st[I].jul)*24.*60.
WHILE NOT (FINITE(st[I].jul) AND FINITE(st[I+1].jul)) DO BEGIN
 I=I+1
 ECHXI = (st[I+1].jul-st[I].jul)*24.*60.
ENDWHILE
 ECHXM = ROUND((TOTAL(-TS_DIFF(st.jul,1),/NAN)/count)*24.*60.)
 Tech  = ECHXI/60. ;c PERIODE D ECHANTILLONNAGE EN HEURES

print,'SAMPLING MOYEN          =',ECHXM,'   MINUTES'
print,'SAMPLING INSTANTANEE    =',ECHXI,'   MINUTES'
print,'SAMPLING  =',Tech,' H','/',Tech/24.,' J'

IF (N GT 50000) THEN BEGIN
   Nt=5000
ENDIF ELSE BEGIN
   Nt=ROUND(N/5.)
ENDELSE

IF ((Tmin*24) LT Tech) THEN BEGIN
   print,'!!!----ATTENTION LA PERIODE MIN EST < A LA PERIODE D ECHANTILLONNAGE'
   EXIT
ENDIF 


CASE 1 OF
   (TMAX EQ 0) AND (TMIN EQ 0): BEGIN
   print,'PAS DE FILTRAGE DES DONNEES'
   xlow    = 0
   xhigh   = 1
                                END
   (TMAX EQ 0) AND (TMIN NE 0): BEGIN
   print,'FILTRE PASSE-BAS',Tmin,'--->Inf'
   xlow    = 0
   xhigh   = (2.*Tech)/(Tmin*24)
                                END
   (TMAX NE 0) AND (TMIN EQ 0): BEGIN
   print,'FILTRE PASSE-HAUT 0--->',Tmax
   xlow    = (2.*Tech)/(Tmax*24)
   xhigh   = 1
                                END
   (TMAX NE 0) AND (TMIN NE 0): BEGIN
   print,'FILTRE ENTRE :',Tmin,' ET ',Tmax
   xlow    = (2.*Tech)/(Tmax*24)
   xhigh   = (2.*Tech)/(Tmin*24)
                                END
ENDCASE

IF ( xlow LT 0 OR xhigh GT 1) THEN BEGIN
   print,'!!!----ATTENTION FREQUENCE INF A NYQUIST'
   EXIT
ENDIF 

coeff   = DIGITAL_FILTER(xlow,xhigh, 50., Nt)
stf     = st
i       = WHERE(FINITE(st.val))
stf[i].val = CONVOL(st[i].val,coeff,/EDGE_WRAP)   

;;derniere modif le 29/04/2003
END
