PRO butterworth_filter,st,sf,tc=tc,pass=pass

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'butterworth_filter, st, sf, tc=tc,pass=1'
 print, ''
 print, 'INPUT : st    --> struct de type {jul,val}'
 print, "INPUT : tc    --> periode de coupure du filtre en jours"
 print, "INPUT : pass  --> 1 pour high pass (defaut low pass)"
 print, 'OUTPUT: sf    --> struct de type {jul,val}'
RETURN
ENDIF

IF n_elements(pass) EQ 0 THEN pass=0
IF n_elements(tc) EQ 0 THEN BEGIN
print,'SPECIFIEZ LA PERIODE DE COUPURE !!'
STOP
ENDIF


N  = N_ELEMENTS(st)
x  = FLTARR(N)
y  = FLTARR(N)
z  = FLTARR(N)


;c CALCUL PERIODE ET FREQUENCE D'ECHANTILLONNAGE DE LA SERIE
;c ---------------------------------------------------------
I     = 0
Tech  = (st[I+1].jul-st[I].jul)*24.
WHILE NOT (FINITE(st[I].jul) AND FINITE(st[I+1].jul)) DO BEGIN
        I = I+1
     Tech = (st[I+1].jul-st[I].jul)*24.
ENDWHILE
nlost = ROUND(tc*24./Tech)
print,'SAMPLING PERIOD     = ',strcompress(Tech,/REMOVE_ALL),' h',' or ',Tech/24.,' J'
print,'NYQUIST  FREQUENCY  = ',strcompress(1/(2.*Tech),/REMOVE_ALL),' cph'
print,'N LOST DATA AT ENDS = ',strcompress(nlost,/REMOVE_ALL)


;c Calcul des coef du filtre pour la frequence de coupure 1/tc
wc = TAN((!PI*Tech)/(tc*24.))
a  = 1+wc+wc*wc
b1 = -2*(wc*wc-1)/a
b2 = -(a-2*wc)/a
c0 = wc*wc/a
c1 = 2*c0
c2 = c0
d0 = wc/(1+wc)
d1 = d0
e1 = -(wc-1)/(wc+1)

;;print,wc,a,b1,b2,c0,c1,c2,d0,d1,e1
it = WHERE(FINITE(st.val,/NAN),cpt)
IF cpt GT 0 THEN st[it].val=MEAN(st.val,/NAN)
x  = st.val
help,x,st

FOR J=0,1 DO BEGIN
   y[0]=x[0]
   y[1]=x[1]
    FOR I=2,N-1 DO y[I]= c0*x[I]+c1*x[I-1]+c2*x[I-2]+b1*y[I-1]+b2*y[I-2] ;c passage du filtre d'ordre 2
   z[0]=y[0]
    FOR I=1,N-1 DO z[I]= d0*y[I]+d1*y[I-1]+e1*z[I-1]                      ;c passage du filtre d'ordre 1
   x= REVERSE(z)                                                          ;c on applique a nouveau le filtrage sur la serie inversee
ENDFOR
;c on flag les nlost valeurs du bout !!
z[0:nlost-1]    = !VALUES.F_NAN
z[N-nlost-1:N-1]= !VALUES.F_NAN

sf    =st
sf.jul=st.jul
sf.val=REVERSE(z)
iz = where(FINITE(sf.val))
IF (N_ELEMENTS(pass) NE 0) THEN BEGIN
sf[iz].val=st[iz].val-sf[iz].val
print,'HIGH PASS'
ENDIF
END
