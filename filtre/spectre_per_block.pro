PRO spectpb, tab, N, delt, n_block, s_smooth, Fq, period, dse, dse_smoothed, Fq_block, period_block, dseblock

IF (N_PARAMS() EQ 0) THEN BEGIN
print, 'UTILISATION:
print, 'spectpb, tab, N, delt,n_block, s_smooth, Fq, period, dse,dse_smoothed,Fq_block, period_block,dseblock'
print, ''
print, 'INPUT: tab,N,delt, n_block, s_smooth'
print, 'OUTPUT: Fq,deriod,dse,dse_smoothed,Fq_block, period_block,dseblock'
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
tab_fft   = FFT(tab)

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

print,'BAND AVERAGING'
dse_smoothed=SMOOTH(dse,s_smooth)


;block averaging
print,'**************BLOCK AVERAGING***********'
t_block=n_elements(tab)/n_block
print,'Nombre de donnees de la serie 1 ',n_elements(tab)
print,'Nombre de block choisies',n_block
print,'Taille des blocks',t_block
print,'DOF =',2*n_block
duree_block       = FLOAT(t_block)*FLOAT(delt)/24. 
freq_ech          = 1./delt
pas_freq_block    = freq_ech/FLOAT(t_block)
temps_block       = delt/3600.* FINDGEN(t_block)  ;temps en heures

print, '**********************CALCUL DU SPECTRE POUR CHAQUE BLOCK********************'
print,"Durée d'un bloc             =",duree_block,'  jours'
print,'Pas en frequence            = ', pas_freq_block, '   cph'
print,'Frequence de Nyquist        =', freq_ech/2., '  cph'

Fq_block        = FINDGEN(t_block/2+1)*pas_freq_block 
Fq_block        = Fq_block[where(Fq_block ne 0)]
period_block    = 1/Fq_block
max_period= MAX(period_block,MIN=min_period)
max_fq    = MAX(fq_block,MIN=min_fq)
print, 'Frequence:   Max=', max_fq , '  Min Frequence =', min_fq
print, 'Periode  :   Max=', max_period , '  Min Periode =', min_period

dseblock    = fltarr(t_block/2+1)
s11         = dcomplexarr(t_block/2+1)

FOR I=1,2*n_block-1 DO BEGIN
	decal      = I*t_block/2

	block      = tab[decal-t_block/2:decal+t_block/2-1]
	
	block_fft  = FFT(1.632993162*HANNING(N_ELEMENTS(block))*block,/DOUBLE)
	
	amp_block  = ABS(block_fft(0:t_block/2))
	pha_block  = ATAN(block_fft(0:t_block/2))
	sblock11   = delt*block_fft(0:t_block/2)*CONJ(block_fft(0:t_block/2))
	
	dseblock   = dseblock  + amp_block^2
	s11        = s11       + sblock11
	
	

max_ampl   = MAX(amp_block        ,MIN=min_ampl)
max_ampls  = MAX(SQRT(ABS(s11/I)) ,MIN=min_ampls)
max_pha    = MAX(pha_block        ,MIN=min_pha)
max_phas   = MAX(IMAGINARY(s11/I) ,MIN=min_phas)
max_dse    = MAX(ABS(s11/I)       ,MIN=min_dse)
print,'***********************BLOCK 1**********************************'
print, 'BLOCK1_Amplitude :  Max=', max_ampl, '  Min=', min_ampl,' -->  S11 : ',max_ampls,min_ampls
print, 'BLOCK1_Phase     :  Max=', max_pha, '  Min=', min_pha ,' -->  S11 : ',max_phas,min_phas
print, 'BLOCK1_Dse       :  Max=', max_ampl^2, '  Min=', min_ampl^2 ,' -->  S11 : ',max_dse,min_dse
ENDFOR

dseblock  = dseblock /(2*n_block-1)
s11       = s11/(2*n_block-1)



END
