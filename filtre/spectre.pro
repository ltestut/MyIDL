PRO spectre, tab, N, delt, Fq, period, dse

IF (N_PARAMS() EQ 0) THEN BEGIN
print, 'UTILISATION:
print, 'spect, tab, N, delt, Fq, period, dse'
print, ''
print, 'INPUT: tab,N,delt'
print, 'OUTPUT: Fq,deriod,dse'
RETURN
ENDIF


duree       = FLOAT(N)*FLOAT(delt)/24. 
freq_ech    = 1./delt
pas_freq    = freq_ech/FLOAT(N)
temps       = delt/3600.* FINDGEN(N)  ;temps en heures

print, '**********************CALCUL DU SPECTRE********************'
print,"Frequence d'echantillonnage = ", freq_ech , '  cph'
print,'Pas en frequence            = ', pas_freq, '   cph'
print,'Frequence de Nyquist        =', freq_ech/2., '  cph'

Fq        = FINDGEN(N/2+1)*pas_freq 
Fq        = Fq[where(Fq ne 0)]
period    = 1/Fq
max_period= MAX(period,MIN=min_period)
max_fq    = MAX(fq,MIN=min_fq)
print, 'Frequence:   Max=', max_fq , '  Min Frequence =', min_fq
print, 'Periode  :   Max=', max_period , '  Min Periode =', min_period


; tab_fft est un vecteur complexe de dimension N
print,'Taille de la serie complete :',n_elements(tab)
print,'Calcul de la FFT sur la plage 0:',N-1
tab_fft   = FFT(tab[0:N-1])

; Amplitude du spectre
amplitude = ABS(tab_fft(0:N/2))
max_ampl  = MAX(amplitude,MIN=min_ampl)

; Phase du spectre
phase     = ATAN(tab_fft(0:N/2))
max_phase = MAX(phase,MIN=min_phase)

; Densite spectrale d'energie
dse       = amplitude^2
max_dse = MAX(dse,MIN=min_dse)
print, 'Amplitude:   Max=', max_ampl, '          Min=', min_ampl
print, 'Phase    :   Max=', max_phase/!DTOR , '  Min=', min_phase/!DTOR
print, 'Dse      :   Max=', max_dse , '          Min=', min_dse

END
