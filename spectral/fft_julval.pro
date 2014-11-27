PRO fft_julval, st_in, sf, kb=kb, Texct=Texct, Nexct=Nexct, _EXTRA=_EXTRA

;c reste un souci de denomination entre dse ? psd ? variance preserving spectra ???

; ***********************************INFO*****************************************
; /!\ Fourrier analysis is based on the assumption of stationary amplitudes, frequencies and phases.  
; There is a difference between IDL FFT definition and the Emery book 'Data Analysis Method in Physical Oceanography'
; 1) For the spectral amplitude -SA- i.e. Fourrier Coefficient
;  In Emery  Yk = Tech.S{yn.(exp[].k)} is SA in [magnitude/cph] (because Tech in hour)
;  In IDL    Yk =(1/N).S{yn.(exp[].k)} is SA in [magnitude] for the frequency k*df with df=1/(N.Tech)
; 2) Order of the FFT
;  In general and for analytical presentation the Fourrier coefficient are surrounded by the Nyquist Frequency -fN<Yk<+fN
;  IDL FFT return a N value array containing the Yk complex fourrier coefficient Y[0:....:N/2:.......:N-1]
;  ordered as below   
;   k=0   : Y0 contains SA for the zero frequency component it is the mean of the serie or block
;   k=1   : Y1 contains SA for the smallest + frequency equal to 1/(N.Tech) (corresponding to the duration of the serie) 
;   k=2   : Y2 contains SA for the frequency of 2/(N.Tech) (corresponding to 1/2 of duration of the serie)
;   k=3   : Y3 contains SA for the frequency of 3/(N.Tech) (corresponding to 1/3 of duration of the serie)
;  ....
;  k=N/2 : YN/2 contains SA for the Nyquist frequency of 1/(2.Tech)  (corresponding to the minimum resolved period)
;  afterwards negative frequencies are stored in the reverse order of positive frequencies,
;             ranging from the highest to lowest negative frequencies. 
; The inverse FFT in IDL gives yn = S{Yk.(exp[].k)}
; The Power Spectral Density or Power Spectrum is 
; The Energy Spectral Density (ESD) describes how the energy of a signal or a time series is distributed with frequency.
; The term energy is used in the generalized sense of signal processing; that is the energy of a signal x(t) 
; One of the results of Fourier analysis is Parseval's theorem which states that the area under the energy spectral density curve
; is equal to the area under the square of the magnitude of the signal, the total energy:
;    The above theorem holds true in the discrete cases as well.
; A similar result holds for power: the area under the power spectral density curve is equal to the total signal power, which is R(0) , the autocorrelation function at zero lag. This is also (up to a constant which depends on the normalization factors chosen in the definitions employed) the variance of the data comprising the signal. 
; La somme des modules pour chaque frequence entre 0:N/2 doit etre egale a 1/2 de la variance du signal y 
; donc le theoreme de 
; Because of the Emery-IDL difference in definition =>  Yk-Emery=(1/Fech)Yk-IDL        
; The PARSEVAL is written 
;        Tech.S{yn^2} =   Fech.S{Yk^2} in Emery form  magnitude^2/
;        Tech.S{yn^2} = 1/Fech.S{Yk^2} in IDL form

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
	print, 'fft_julval, st, sf, kb=Nbloc, Texct=T_exacte, Nexct=Ndata'
	print, ''
	print, 'INPUT:  st       --> de type {jul,val}'
	print, 'INPUT:  N_block  --> Nbr de block pour le calcul de la FFT (choisir un multiple de 2)'
	print, 'INPUT:  T_exacte --> Calcul du N_block optimun pour tomber sur T_exacte'
	print, 'INPUT:  Ndata    --> on force le nombre de donnees a prendre en cpte'
	print, 'OUTPUT: sf       --> de type {frq,prd,psd,fft}'
RETURN
ENDIF

IF NOT KEYWORD_SET(kb)    THEN kb=1                              ;default number of blocks
IF NOT KEYWORD_SET(Nexct) THEN N=N_ELEMENTS(st_in) ELSE  N=Nexct ;to force the number of data taken into account
info = STRARR(30)

 ; basic stat of the serie
st        = st_in[0:N-1]
iz        = WHERE(FINITE(st.val),count)
rgr       = LINFIT(st[iz].jul,st[iz].val,SIGMA=rgrerr)
sampling  = sampling_julval(st,/NOROUND)  ;mean sampling value in second
duration  = duration_julval(st)           ;duration of the time serie in day
Tech      = sampling/3600.                ;sampling in hours
nyq_frq   = 1/(2.*Tech)                   ;Nyquist frequency in cph
nyq_prq   = 2.*Tech                       ;Nyquist period in hour

 ;force N to be even or N to have exact period Texct
IF KEYWORD_SET(Texct) THEN BEGIN
	tab_n = (FINDGEN(N+1)*Tech/Texct)-ROUND(FINDGEN(N+1)*Tech/Texct)
	iz1   = WHERE(ABS(tab_n) LE 0.0001,cpt1)                         ;c indice des n entiers
	iz2   = WHERE(((float(iz1)/2.-float(ROUND(iz1/2))) EQ 0. ),cpt2) ;c indice des n entiers pairs
	IF (cpt1 GE 1 AND cpt2 GT 1) THEN N = MAX(iz1[iz2])              ;c N devient le plus grand entier pair 
	IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1           ;c si N est impair il devient pair
ENDIF ELSE BEGIN 
	IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1           ;c si N est impair il devient pair
      Texct='None'
ENDELSE

 ;fill the info string
original_info =   ['ORIGINAL DATA  :',$
        STRING(' - Ndata[Ngap]   : ',STRCOMPRESS(N_ELEMENTS(st),/REMOVE_ALL),' [',STRCOMPRESS(N_ELEMENTS(st)-count,/REMOVE_ALL),']'),$
        STRING(' - Mean & rms    : ',STRCOMPRESS(MEAN(st.val,/NAN),/REMOVE_ALL),' & ',STRCOMPRESS(STDDEV(st.val,/NAN))),$
        STRING(' - Trend /year   : Y(t)=',STRCOMPRESS((rgr[1]*365.),/REMOVE_ALL),'*t + ',STRCOMPRESS((rgr[0]),/REMOVE_ALL),'  +/- ',strcompress(rgrerr[1],/REMOVE_ALL)),$
        STRING(' - Sampling      : ',STRCOMPRESS(STRING(ROUND(sampling)   ,FORMAT='(I7)')       ,/REMOVE_ALL) ,' sec / ',$
                                             STRCOMPRESS(STRING(sampling/60.        ,FORMAT='(F10.1)')    ,/REMOVE_ALL) ,' mn / ',$
                                             STRCOMPRESS(STRING(sampling/3600.      ,FORMAT='(F10.1)')    ,/REMOVE_ALL) ,' hr / ',$
                                             STRCOMPRESS(STRING(sampling/(3600.*24.),FORMAT='(F10.4)'),/REMOVE_ALL)     ,' day'),$
        STRING(' - Duration      : ',STRCOMPRESS(STRING(ROUND(duration)             ,FORMAT='(I7)')       ,/REMOVE_ALL) ,' days / ',$
                                             STRCOMPRESS(STRING(duration*24.        ,FORMAT='(F10.1)')    ,/REMOVE_ALL) ,' hr / ',$
                                             STRCOMPRESS(STRING(duration/365.       ,FORMAT='(F12.1)')    ,/REMOVE_ALL) ,' yr / ',$
                                             STRCOMPRESS(STRING(ROUND(duration*3600.*24.)  ,FORMAT='(I10)'),/REMOVE_ALL)     ,' sec'),$
        STRING(' - Nyquist frq   : ',STRCOMPRESS(STRING(nyq_frq     ,FORMAT='(F10.4)'),/REMOVE_ALL),' cph / ',$
                                   STRCOMPRESS(STRING(24.*nyq_frq ,FORMAT='(F10.4)'),/REMOVE_ALL),' cpd'),$
        STRING(' - Nyquist prq   : ',STRCOMPRESS(STRING(nyq_prq     ,FORMAT='(F10.4)'),/REMOVE_ALL),'  hr / ',$
                                  STRCOMPRESS(STRING(nyq_prq/24. ,FORMAT='(F10.4)'),/REMOVE_ALL),' day'),$
        STRING(' - Period choice : Texct= ',STRCOMPRESS(Texct,/REMOVE_ALL),' ==> Ndata= ',STRCOMPRESS(N,/REMOVE_ALL))$                                                                        
              ]

 ;cut serie in blocks
N       = N/kb                                            ;nbre elements of each block 
IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1    ;force N to be even
DOF     = kb*2                                            ;degree of freedom
Fech    = 1./(N*Tech)                                     ;sampling frequency in cph 
frq     = FINDGEN(N/2+1)*Fech                             ;frequency vector from 0 to (N/2)*Fech
max_frq = MAX(frq,MIN=min_frq)                            ;min and max of frequency vector
prd     = [N*Tech,1/frq[WHERE(frq NE 0)]]                 ;period vector 
max_prd = MAX(prd,MIN=min_prd)                            ;min and max of period vector

PRINT,'Frq: Max=',STRCOMPRESS(STRING(max_frq,FORMAT='(F10.4)'),/REMOVE_ALL),' cph / ',STRCOMPRESS(STRING(max_frq*3600.,FORMAT='(F10.4)'),/REMOVE_ALL),' cph',$
         '  Min=', STRCOMPRESS(min_frq),' cph'
PRINT,'Prd: Min=',STRCOMPRESS(STRING(min_prd,FORMAT='(F10.4)'),/REMOVE_ALL),' h   / ',STRCOMPRESS(STRING(min_prd*3600.,FORMAT='(F10.4)'),/REMOVE_ALL),' hr',$
         '  Max=',STRCOMPRESS(max_prd),' h'

;info[8:13]         
block_info = [STRING('NUMBER OF BLOCKS [DOF] : ',STRCOMPRESS(kb),'[',STRCOMPRESS(DOF),']'),$
              STRING(' - Ndata per block     : ',STRCOMPRESS(N,/REMOVE_ALL)),$
              STRING(' - Size of frq vector  : ',STRCOMPRESS(N/2+1,/REMOVE_ALL)),$
              STRING(' - Sampling frq  [df]  : ',STRING(Fech)    ,' cph',$
                                                      STRING(Fech*24.),' cpd'),$
              STRING(' - Minimal period      : ',STRING(min_prd                ,FORMAT='(F12.4)'),' hr /',$
                                                      STRING(min_prd/24.       ,FORMAT='(F12.6)'),' day /',$
                                                      STRING(min_prd/(24.*365.),FORMAT='(F12.7)'),' year'),$
              STRING(' - Fondamental period  : ',STRING(max_prd                ,FORMAT='(F12.2)'),' hr /',$
                                                      STRING(max_prd/24.       ,FORMAT='(F12.2)'),' day /',$
                                                      STRING(max_prd/(24.*365.),FORMAT='(F12.2)'),' year')]

info =[original_info,block_info]
print,TRANSPOSE(info)
psd_mean   = FLTARR(N/2+1)         ;c valeur des amplitudes^2 moyennes pour chaque frequence
block_mean = DCOMPLEXARR(N)        ;c valeur des coeff fft moyens pour chaque frequence
prdmax     = FLTARR(2*kb-1)
psdmax     = FLTARR(2*kb-1)
ampmax     = FLTARR(2*kb-1)

;c Windowing 
hanning_coef   = SQRT(8./3.) 
hanning_window = hanning_coef*HANNING(N)

FOR I=1,2*kb-1 DO BEGIN
	decal      = I*N/2
	block      = st[decal-N/2:decal+N/2-1].val
	mblock     = MOMENT(block,/NAN,SDEV=sdevblock)         ;computes the mean, variance, skewness and kurtosis
	iz         = WHERE(FINITE(block))
	rgrblock   = LINFIT(iz,block[iz],SIGMA=errblock)       ;compute then trend 	
	block[iz]  = block[iz]-(rgrblock[0]+rgrblock[1]*iz)    ;remove trend
	inan       = WHERE(FINITE(block,/NAN),cpt)
	IF (cpt GE 1) THEN block[inan]= MEAN(block,/NAN)       ;replace gap with mean value
  block      = block - MEAN(block,/NAN)                  ;remove mean of the block
	psl_prd    = TOTAL(block^2)*Tech                       ;compute the total energy of the block in the temporal domain
	raw_fft    = FFT(block,/DOUBLE)                        ;compute FFT before "windowing"
  psl_frq    = TOTAL(ABS(raw_fft)^2)/Fech                ;compute the total energy of the block in the spectral domain
	block_fft  = FFT(hanning_window*block,/DOUBLE)         ;compute FFT after "windowing"
  block_mean = block_mean + block_fft                    ;store the FFT of each block
	s11       = 2*(block_fft(0:N/2)*CONJ(block_fft(0:N/2)))       ;energy spectral density  : S11k = 2.Yk.Yk* (avec y_k'=conjuge de Y_k)
	amp       = 2*ABS(block_fft(0:N/2))                           ;amplitude         : Ak
	pha       = ATAN(block_fft(0:N/2),/PHASE)*(360./(2*!PI))+180. ;phase             : Thetak (en degres)
	
	psd_mean = psd_mean  + s11                      ;c c'est d'apres le cours de Klaus la puissance moyenne du signal
			                               ;c integree sur la bande de frequence 
	                                               ;c == integrale de la dse sur la bande de frequence

max_amp   = MAX(amp  ,MIN=min_amp)
max_pha   = MAX(pha  ,MIN=min_pha)
max_psd   = MAX(s11  ,MIN=min_psd)
imax      = WHERE(amp EQ max_amp)
prdmax[I-1] = prd[imax] 
psdmax[I-1] = s11[imax]
ampmax[I-1] = amp[imax] 
print,'***************BLOCK',strcompress(I,/REMOVE_ALL),'**********************************'
print,'Original Mean & rms        : ',strcompress(mblock[0],/REMOVE_ALL),' & ',strcompress(sdevblock)
print,'Removed Trend and mean     : Y(t)=',strcompress((rgrblock[1]*365.),/REMOVE_ALL),'*t + ',strcompress((rgrblock[0]),/REMOVE_ALL)
print,'Mean & rms                 : ',strcompress(MEAN(block,/NAN),/REMOVE_ALL),' & ',strcompress(STDDEV(block,/NAN))
print,'PARSEVAL                   : ',strcompress(abs(psl_prd-psl_frq)*1000000./psl_prd,/REMOVE_ALL),' ppm'
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
sf={ frq:FLTARR(N/2+1), prd:FLTARR(N/2+1), psd:FLTARR(N/2+1), amp:FLTARR(N/2+1), fft:DCOMPLEXARR(N), $
    info:STRARR(N_ELEMENTS(info)), prdmax:FLTARR(2*kb-1) , psdmax:FLTARR(2*kb-1), ampmax:FLTARR(2*kb-1)}
sf.frq=frq
sf.prd=prd
sf.psd=psd_mean
sf.amp=amp
sf.fft=block_mean
sf.info=info
sf.prdmax=prdmax
sf.psdmax=psdmax
sf.ampmax=ampmax

;c definir une structure qui permettent de transmettre les informations a plot_fft

;; Derniere Modif le 20/02/2008
END
