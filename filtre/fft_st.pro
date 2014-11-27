PRO fft_st, st, sf

IF (N_PARAMS() EQ 0) THEN BEGIN
	print, 'UTILISATION:
	print, 'fft_st, st,sf'
	print, ''
	print, 'INPUT:  st --> de type {jul,val}'
	print, 'OUTPUT: sf --> de type {frq,prd,dse}'
RETURN
ENDIF

;c CALCUL DES PERIODES MOYENNE ET INSTANTANEE D'ECHANTILLONNAGE DE LA SERIE
;c ------------------------------------------------------------------------
N     = N_ELEMENTS(st)
it    = WHERE(FINITE(st.val,/NAN),count)
I     = 0
ECHXI = (st[I+1].jul-st[I].jul)*24.*60.
WHILE NOT (FINITE(st[I].jul) AND FINITE(st[I+1].jul)) DO BEGIN
 I=I+1
 ECHXI = (st[I+1].jul-st[I].jul)*24.*60.
ENDWHILE
  Tech = ECHXI/60.
print,'SAMPLING INSTANT    =',ECHXI,'   MINUTES'
print,'SAMPLING  =',Tech,' H','/',Tech/24.,' J'
;c ON REMPLACE LES /NAN PAR LA MOYENNE
;c -----------------------------------
IF (count NE 0) THEN st[it].val=MEAN(st.val,/NAN)
;c ON FORCE UN NBRE PAIR D'ELEMENTS
;c --------------------------------
DN          = 0
IF ( (float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN DN=1 ;c SI N EST IMPAIR
N           = N-DN
tab         = st[0:N-1].val   ;c tab d'un nombre de valeur pair
freq_ech    = 60./ECHXI       ;c -en heures
pas_freq    = freq_ech/FLOAT(N)
print, '**********************CALCUL DU SPECTRE********************'
print,'Frequence d echantillonnage =',strcompress(freq_ech,/REMOVE_ALL), ' cph'
print,'Pas en frequence            =',strcompress(pas_freq,/REMOVE_ALL), ' cph'
print,'Frequence de Nyquist        =',strcompress(freq_ech/2.,/REMOVE_ALL),' cph'
Fq        = FINDGEN(N/2+1)*pas_freq 
Fq        = Fq[where(Fq ne 0)]
period    = 1/Fq
max_period= MAX(period,MIN=min_period)
max_fq    = MAX(fq,MIN=min_fq)
print, 'Frq: Max=',strcompress(max_fq),'  Min=', min_fq
print, 'Prd: Max=',strcompress(max_period),'h','  Min=',strcompress(min_period),'h'

;c tab_fft est un vecteur complexe de dimension N
print,'Taille de la serie complete :',N
print,'Calcul de la FFT sur la plage [0:',strcompress(N-1,/REMOVE_ALL),']'
tab_fft   = FFT(tab)

;c Amplitude du spectre
amplitude = ABS(tab_fft(1:N/2))
max_ampl  = MAX(amplitude,MIN=min_ampl)

;c Phase du spectre
phase     = ATAN(tab_fft(1:N/2))
max_phase = MAX(phase,MIN=min_phase)

;c Densite spectrale d'energie
dse       = amplitude^2
max_dse = MAX(dse,MIN=min_dse)
print, 'Amplitude:   Max=',strcompress(max_ampl,/REMOVE_ALL), '          Min=',strcompress(min_ampl,/REMOVE_ALL)
print, 'Phase    :   Max=',strcompress(max_phase/!DTOR,/REMOVE_ALL) , '  Min=',strcompress(min_phase/!DTOR,/REMOVE_ALL)
print, 'Dse      :   Max=',strcompress(max_dse,/REMOVE_ALL), '          Min=',strcompress(min_dse,/REMOVE_ALL)

tmp={frq:0.0,prd:0.0,dse:0.0}
sf=REPLICATE(tmp,N_ELEMENTS(dse))
sf.frq=Fq
sf.prd=period
sf.dse=dse

;; Derniere Modif le 15/04/2003
END
