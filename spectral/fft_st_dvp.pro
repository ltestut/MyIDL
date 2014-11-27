PRO fft_st_dvp, st, sf, kb=kb, Texct=Texct, Nexct=Nexct

;c reste un souci de denomination entre dse ? psd ? variance preserving spectra ???

;; ***********************************INFO*****************************************
;; ATTENTION il y a une difference entre la definition de la FFT selon IDL et selon
;;           'Data Analysis Method in Physical Oceanography'
;; pour IDL: Yk =(1/N) S yn.Exp(...) 
;; pour IDL: yn = S Yk*Exp(...)
;; Yk est le coefficient de la FFT pour la frequence k*df --> donc Y0=moyenne des yn
;; les N coefficients Yk sont complexes de Y[0:....:N/2:.......:N-1]
;; yn s'ecrit donc comme la somme des coefficients Yk pour chaque frequence
;; Yk a donc la meme unite que yn, donc Yk exprime l'amplitude à la frequence k
;; La somme des modules pour chaque frequence entre 0:N/2 doit etre egale a 1/2 de la variance du signal y 
;; donc le theoreme de PARSEVAL s'ecrit sous la forme:
;;                                      S Yk^2=(1/2N)S yn^2

IF (N_PARAMS() EQ 0) THEN BEGIN
	print, 'DESCRIPTION:'
        print, 'calcul par bloc de la FFT d une serie temporelle de type {jul,val}'
        print, ' - La tendance est enlevee a chaque bloc'
        print, ' - Les trous sont remplaces par la valeur moyenne de la serie'
        print, ' - Le block est multiplie par une fenetre de Hanning'
        print, ' - La moyenne de la serie est enlevee'
        print, ' - Il y a un recouvrement de 50% des blocs'
        print, ''
	print, 'UTILISATION:'
	print, 'fft_st, st, sf, kb=Nbloc, Texct=T_exacte, Nexct=Ndata'
	print, ''
	print, 'INPUT:  st       --> de type {jul,val}'
	print, 'INPUT:  N_block  --> Nbr de block pour le calcul de la FFT (choisir un multiple de 2)'
	print, 'INPUT:  T_exacte --> Calcul du N_block optimun pour tomber sur T_exacte'
	print, 'INPUT:  Ndata    --> on force le nombre de donnees a prendre en cpte'
	print, 'OUTPUT: sf       --> de type {frq,prd,psd,fft}'
RETURN
ENDIF

IF (N_ELEMENTS(kb) EQ 0) THEN kb=1
info = strarr(15)

;c STATISTIQUES SUR LA SERIE
;c -------------------------
N         = N_ELEMENTS(st)
IF (N_ELEMENTS(Nexct) NE 0) THEN N=Nexct   ;c on force le nbre de donnees a prendre en cpte utile pour coherence
iz        = WHERE(FINITE(st[0:N-1].val))
it        = WHERE(FINITE(st[0:N-1].val,/NAN),count)
rgr       = LINFIT(st[iz].jul,st[iz].val,SIGMA=rgrerr)

info[0:3] =   ['ORIGINAL DATA :',$
        STRING(' Ndata[Ntrou] : ',strcompress(N,/REMOVE_ALL),' [',strcompress(count,/REMOVE_ALL),']'),$
        STRING(' Mean & rms   : ',strcompress(MEAN(st.val,/NAN),/REMOVE_ALL),' & ',strcompress(STDDEV(st.val,/NAN))),$
        STRING(' Trend /year  : Y(t)=',strcompress((rgr[1]*365.),/REMOVE_ALL),'*t + ',strcompress((rgr[0]),/REMOVE_ALL),'  +/-',strcompress(rgrerr[1],/REMOVE_ALL))$
              ]
print,'Original Ndata[Ntrou] : ',strcompress(N,/REMOVE_ALL),' [',strcompress(count,/REMOVE_ALL),']'
print,'Original Mean & rms   : ',strcompress(MEAN(st.val,/NAN),/REMOVE_ALL),' & ',strcompress(STDDEV(st.val,/NAN))
print,'Trend in unit/year    : Y(t)=',strcompress((rgr[1]*365.),/REMOVE_ALL),'*t + ',strcompress((rgr[0]),/REMOVE_ALL),'  +/-',strcompress(rgrerr[1],/REMOVE_ALL)

;c CALCUL PERIODE ET FREQUENCE D'ECHANTILLONNAGE DE LA SERIE
;c ---------------------------------------------------------
I     = 0
Tech  = (st[I+1].jul-st[I].jul)*24.
WHILE NOT (FINITE(st[I].jul) AND FINITE(st[I+1].jul)) DO BEGIN
        I = I+1
     Tech = (st[I+1].jul-st[I].jul)*24.
ENDWHILE
print,'SAMPLING PERIOD    = ',strcompress(Tech,/REMOVE_ALL),' h',' or ',Tech/24.,' J'
print,'NYQUIST  FREQUENCY = ',strcompress(1/(2.*Tech),/REMOVE_ALL),' cph'


;c ON FORCE LE NBRE TOTAL D'ELEMENTS POUR TOMBER SUR TEXCT ET N PAIR
;c --------------------------------------------------------------------
IF (N_ELEMENTS(Texct) EQ 1) THEN BEGIN
	tab_n = (FINDGEN(N+1)*Tech/Texct)-ROUND(FINDGEN(N+1)*Tech/Texct)
	iz1   = WHERE(ABS(tab_n) LE 0.0001,cpt1)                         ;c indice des n entiers
	iz2   = WHERE(((float(iz1)/2.-float(ROUND(iz1/2))) EQ 0. ),cpt2) ;c indice des n entiers pairs
	IF (cpt1 GE 1 AND cpt2 GT 1) THEN N = MAX(iz1[iz2])              ;c N devient le plus grand entier pair 
	IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1           ;c si N est impair il devient pair
ENDIF ELSE BEGIN 
	IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1           ;c si N est impair il devient pair
      Texct='None'
ENDELSE
info[4:6] = ['',STRING('CHOICE OF EXACT PERIOD   : Texct= ',strcompress(Texct,/REMOVE_ALL),' ==> Ndata= ',strcompress(N,/REMOVE_ALL)),'']
print,STRING('CHOICE OF EXACT PERIOD   : Texct= ',strcompress(Texct,/REMOVE_ALL),' ==> Ndata= ',strcompress(N,/REMOVE_ALL))
print,'NDATA              = ',strcompress(N,/REMOVE_ALL)

;c DECOUPAGE EN BLOC DE LA SERIE ET CALCUL DE LA FFT
;c -------------------------------------------------
N       = N/kb
IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1           ;c si N est impair il devient pair
DOF     = kb*2
Fech    = 1./(N*Tech)    ;; en cph 
frq     = FINDGEN(N/2+1)*Fech
prd     = [N*Tech,1/frq[WHERE(frq NE 0)]]
max_prd = MAX(prd,MIN=min_prd)
max_frq = MAX(frq,MIN=min_frq)

print, '**********************CALCUL DU SPECTRE********************'
print,'SAMPLING FREQUENCY:',strcompress(Fech,/REMOVE_ALL),' cph'
print,'Nbloc             :',strcompress(kb,/REMOVE_ALL)
print,'DOF               :',strcompress(DOF,/REMOVE_ALL)
print,'Ndata before FFT  :',strcompress(N,/REMOVE_ALL),' Calcul sur la plage [0:',strcompress(N-1,/REMOVE_ALL),']'
print,'Frq: Max=',strcompress(max_frq),' cph','[',strcompress(max_frq*60.),' cpm]','  Min=', strcompress(min_frq),' cph'
print,'Prd: Min=',strcompress(min_prd),' h'  ,'[',strcompress(min_prd*60.),' min]','  Max=',strcompress(max_prd),' h'
info[7:14] = [STRING('NUMBER OF BLOCKS [DOF] : ',strcompress(kb),'[',strcompress(DOF),']'),$
              STRING(' Ndata             : ',strcompress(N,/REMOVE_ALL)),$
              STRING(' Sampling period   : ',strcompress(Tech,/REMOVE_ALL),' h',' or ',Tech/24.,' J'),$
              STRING(' Sampling frequency: ',strcompress(Fech,/REMOVE_ALL),' cph'),$
              STRING(' Nyquist  frequency: ',strcompress(1/(2.*Tech),/REMOVE_ALL),' cph'),$
              STRING(' Frq: Max=',strcompress(max_frq),'cph','  Min=', strcompress(min_frq),'cph'),$
              STRING(' Prd: Max=',strcompress(max_prd),'h'  ,'  Min=',strcompress(min_prd),'h'),$
              '']

psd_mean  = fltarr(N/2+1)      ;c valeur des amplitudes^2 moyennes pour chaque frequence
block_mean= dcomplexarr(N/2+1) ;c valeur des coeff fft moyens pour chaque frequence
prdmax    = fltarr(2*kb-1)
psdmax    = fltarr(2*kb-1)

FOR I=1,2*kb-1 DO BEGIN
	decal      = I*N/2
	block      = st[decal-N/2:decal+N/2-1].val
	mblock     = MOMENT(block,/NAN,SDEV=sdevblock)
	iz         = WHERE(FINITE(block))
	rgrblock   = LINFIT(iz,block[iz],SIGMA=errblock) 	
	block[iz]  = block[iz]-(rgrblock[0]+rgrblock[1]*iz)       ;c on enleve la tendance du bloc
	
	inan       = WHERE(FINITE(block,/NAN),cpt)
	IF (cpt GE 1) THEN block[inan]= MEAN(block,/NAN)          ;c on remplace les trous par la moyenne du bloc
        block      = block - MEAN(block,/NAN)                     ;c on enleve la moyenne du bloc
	psl_prd    = TOTAL((block*block))/N
        block      = HANNING(N_ELEMENTS(block))*block             ;c on applique une fenetre hanning
	block_fft  = 1.632993162*FFT(block,/DOUBLE)               ;c on calcul la FFT du bloc en pour prendre en cpt le fenetrage 
        block_mean = block_mean + 2*block_fft[0:N/2]              ;c on calcul la valeur de la fft moyenne
	
	amp  = 2*ABS(block_fft(0:N/2))
	pha  = 2*ATAN(block_fft(0:N/2))
	s11  = 2*ABS(block_fft(0:N/2)*CONJ(block_fft(0:N/2)))  ;c module de l'amplitude pour chaque frequence (x2 pour la symetrie)	
	psd_mean = psd_mean  + s11                             ;c c'est d'apres le cours de Klaus la puissance moyenne du signal
			                                       ;c integree sur la bande de frequence 
	                                                       ;c == integrale de la dse sur la bande de frequence
max_amp   = MAX(amp  ,MIN=min_amp)
max_pha   = MAX(pha  ,MIN=min_pha)
max_psd   = MAX(s11  ,MIN=min_psd)
psl_frq   = TOTAL(s11)
imax      = WHERE(amp EQ max_amp)
prdmax[I-1] = prd[imax] 
psdmax[I-1] = s11[imax] 
print,'***************BLOCK',strcompress(I,/REMOVE_ALL),'**********************************'
print,'Original Mean & rms        : ',strcompress(mblock[0],/REMOVE_ALL),' & ',strcompress(sdevblock)
print,'Removed Trend and mean     : Y(t)=',strcompress((rgrblock[1]*365.),/REMOVE_ALL),'*t + ',strcompress((rgrblock[0]),/REMOVE_ALL)
print,'Mean & rms                 : ',strcompress(MEAN(block,/NAN),/REMOVE_ALL),' & ',strcompress(STDDEV(block,/NAN))
print,'PARSEVAL                   : ',strcompress(abs(psl_prd-psl_frq),/REMOVE_ALL)
print,'Amp: Max=',strcompress(max_amp,/REMOVE_ALL), '  Min=',strcompress(min_amp,/REMOVE_ALL),' Tmax=',prd[imax]
print,'Pha: Max=',strcompress(max_pha,/REMOVE_ALL), '  Min=',strcompress(min_pha,/REMOVE_ALL)
print,'psd: Max=',strcompress(max_psd,/REMOVE_ALL), '  Min=',strcompress(min_psd,/REMOVE_ALL)
ENDFOR

psd_mean   = psd_mean/(2*kb-1)
block_mean = block_mean/(2*kb-1)

;c mettre des calculs de min et max pour les periodes at ampl
;c verifier que la psd moyenne est bien egale a la psd de la moyenne des blocs !!
;c ON REMPLIT LA STRUCTURE DE TYPE FFT
;c -----------------------------------
sf={ frq:FLTARR(N/2+1), prd:FLTARR(N/2+1), psd:FLTARR(N/2+1), fft:DCOMPLEXARR(N/2+1), $
    info:STRARR(N_ELEMENTS(info)), prdmax:FLTARR(2*kb-1) , psdmax:FLTARR(2*kb-1)}
sf.frq=frq
sf.prd=prd
sf.psd=psd_mean
sf.fft=block_mean
sf.info=info
sf.prdmax=prdmax
sf.psdmax=psdmax

;c definir une structure qui permettent de tranmettre les informations a plot_fft

;; Derniere Modif le 12/02/2004
END
