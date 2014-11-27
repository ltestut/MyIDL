PRO fft_st_per_block, st, sf, sfb, n_block

IF (N_PARAMS() EQ 0) THEN BEGIN
	print, 'UTILISATION:
	print, 'fft_st_per_block, st, stf, stfb, n_block'
	print, ''
	print, 'INPUT:  st --> de type {jul,val}'
	print, 'OUTPUT: sf,sfb --> de type {frq,prd,dse}'
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
;;Fq        = Fq[where(Fq ne 0)]
period    = [!VALUES.F_NAN,1/Fq[where(Fq ne 0)]] ;;1/Fq
max_period= MAX(period,MIN=min_period)
max_fq    = MAX(fq,MIN=min_fq)
print, 'Frq: Max=',strcompress(max_fq),'  Min=', min_fq
print, 'Prd: Max=',strcompress(max_period),'h','  Min=',strcompress(min_period),'h'

;c tab_fft est un vecteur complexe de dimension N
print,'Taille de la serie complete :',N
print,'Calcul de la FFT sur la plage [0:',strcompress(N-1,/REMOVE_ALL),']'
tab_fft   = FFT(tab)

;c Amplitude du spectre
amplitude = ABS(tab_fft(0:N/2))
max_ampl  = MAX(amplitude,MIN=min_ampl)

;c Phase du spectre
phase     = ATAN(tab_fft(0:N/2))
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

;c block averaging
print,'**************BLOCK AVERAGING***********'
t_block=n_elements(tab)/n_block
print,'Nombre de block:',strcompress(n_block,/REMOVE_ALL)
print,'Taille des blocks:',strcompress(t_block,/REMOVE_ALL)
print,'DOF =',2*n_block
duree_block       = FLOAT(t_block)*FLOAT(Tech)/24. 
pas_freq_block    = freq_ech/FLOAT(t_block)
temps_block       = Tech/3600.*FINDGEN(t_block)  ;temps en heures
print, '************CALCUL DU SPECTRE POUR CHAQUE BLOCK**'
print,"Durée d'un bloc  =",strcompress(duree_block,/REMOVE_ALL),'  jours'
print,'Pas en frequence = ',strcompress(pas_freq_block,/REMOVE_ALL), '   cph'
Fq_block        = FINDGEN(t_block/2+1)*pas_freq_block 
;;Fq_block        = Fq_block[where(Fq_block ne 0)]
period_block    = [!VALUES.F_NAN,1/Fq_block[where(Fq_block ne 0)]]
max_period= MAX(period_block,MIN=min_period)
max_fq    = MAX(fq_block,MIN=min_fq)
print, 'Frequence:  Max=',strcompress(max_fq,/REMOVE_ALL) , '  Min Frequence =',strcompress(min_fq,/REMOVE_ALL)
print, 'Periode  :  Max=',strcompress(max_period,/REMOVE_ALL) , '  Min Periode =',strcompress(min_period,/REMOVE_ALL)

dseblock    = fltarr(t_block/2+1)
s11         = dcomplexarr(t_block/2+1)

FOR I=1,2*n_block-1 DO BEGIN
	decal      = I*t_block/2

	block      = tab[decal-t_block/2:decal+t_block/2-1]
	
;;	block_fft  = FFT(1.632993162*HANNING(N_ELEMENTS(block))*block,/DOUBLE)
	block_fft  = FFT(block,/DOUBLE)
	
	amp_block  = ABS(block_fft(0:t_block/2))
	pha_block  = ATAN(block_fft(0:t_block/2))
	sblock11   = Tech*block_fft(0:t_block/2)*CONJ(block_fft(0:t_block/2))
	
	dseblock   = dseblock  + amp_block^2
	s11        = s11       + sblock11
	
max_ampl   = MAX(amp_block        ,MIN=min_ampl)
max_ampls  = MAX(SQRT(ABS(s11/I)) ,MIN=min_ampls)
max_pha    = MAX(pha_block        ,MIN=min_pha)
max_phas   = MAX(IMAGINARY(s11/I) ,MIN=min_phas)
max_dse    = MAX(ABS(s11/I)       ,MIN=min_dse)
print,'***************BLOCK',strcompress(I,/REMOVE_ALL),'**********************************'
print, 'BLOCK_Amplitude :  Max=',strcompress(max_ampl,/REMOVE_ALL), '  Min=',strcompress(min_ampl,/REMOVE_ALL),' -->  S11 : ',strcompress(max_ampls,/REMOVE_ALL),strcompress(min_ampls,/REMOVE_ALL)
print, 'BLOCK_Phase     :  Max=',strcompress(max_pha,/REMOVE_ALL), '  Min=',strcompress(min_pha,/REMOVE_ALL),' -->  S11 : ',strcompress(max_phas,/REMOVE_ALL),strcompress(min_phas,/REMOVE_ALL)
print, 'BLOCK_Dse       :  Max=',strcompress(max_ampl^2,/REMOVE_ALL), '  Min=',strcompress(min_ampl^2,/REMOVE_ALL) ,' -->  S11 : ',strcompress(max_dse,/REMOVE_ALL),strcompress(min_dse,/REMOVE_ALL)
ENDFOR

dseblock  = dseblock/(2*n_block-1)
s11       = s11/(2*n_block-1)


sfb=REPLICATE(tmp,N_ELEMENTS(dseblock))
sfb.frq=Fq_block
sfb.prd=period_block
sfb.dse=dseblock


END
