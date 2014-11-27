PRO fft_matrix, z, t, prd, kb=kb, amp=amp_mean, pha=pha_mean, s11=s11_mean 
; Z is a 3D matrix where dimension 3 is the time dimension: FFT(z,-1,DIMENSION=3)
; t is the time array of the matrix
; output : amp is the amplitude for ecah prd
;        : pha is the phase     for ecah prd
;        : s11 is the density   for ecah prd

IF (N_ELEMENTS(kb) EQ 0) THEN kb=1
info = STRARR(15)
s    = SIZE(z)
N    = N_ELEMENTS(t)

;calcul de la periode d'echantillonnage
tech  = DOUBLE((t[1]-t[0]))*24. 
print,"Valeur de l'echantillonnage en heures =",tech 

;decoupage en bloc de la serie
N       = N/kb                                                  ;c nbre d'elements de chaque bloc 
IF ((float(N)/2.-float(ROUND(N/2))) NE 0. ) THEN N=N-1      ;c si N est impair il devient pair
DOF     = kb*2
fech    = 1./(N*tech)                                       ; en cph 
frq     = FINDGEN(N/2+1)*fech
prd     = [N*tech,1/frq[WHERE(frq NE 0)]]
max_prd = MAX(prd,MIN=min_prd)
max_frq = MAX(frq,MIN=min_frq)

print, '**********************CALCUL DU SPECTRE********************'
print,'Spectral sampling interval :',strcompress(fech,/REMOVE_ALL),' cph'
print,'Nbre de bloc               :',strcompress(kb,/REMOVE_ALL)
print,'DOF                        :',strcompress(DOF,/REMOVE_ALL)
print,'Ndata before FFT           :',strcompress(N,/REMOVE_ALL),' Calcul sur la plage [0:',strcompress(N-1,/REMOVE_ALL),']'
print,'Frq: Max=',strcompress(max_frq),' cph','[',strcompress(max_frq*60.),' cpm]','  Min=', strcompress(min_frq),' cph'
print,'Prd: Min=',strcompress(min_prd),' h'  ,'[',strcompress(min_prd*60.),' min]','  Max=',strcompress(max_prd),' h'

info[7:14] = [STRING('NUMBER OF BLOCKS [DOF] : ',strcompress(kb),'[',strcompress(DOF),']'),$
              STRING(' Ndata             : ',strcompress(N,/REMOVE_ALL)),$
              STRING(' Sampling period   : ',strcompress(Tech,/REMOVE_ALL),' h',' or ',Tech/24.,' J'),$
              STRING(' Sampling frequency: ',strcompress(Fech,/REMOVE_ALL),' cph'),$
              STRING(' Nyquist  frequency: ',strcompress(1/(2.*Tech),/REMOVE_ALL),' cph'),$
              STRING(' Frq: Max=',strcompress(max_frq),'cph','  Min=', strcompress(min_frq),'cph'),$
              STRING(' Prd: Max=',strcompress(max_prd),'h  ','  Min=',strcompress(min_prd),'h'),$
              '']
              
psd_mean   = FLTARR(s[1],s[2],N/2+1)      ;c valeur des amplitudes^2 moyennes pour chaque frequence
amp_mean   = FLTARR(s[1],s[2],N/2+1)      ;c valeur des amplitudes   moyennes pour chaque frequence
pha_mean   = FLTARR(s[1],s[2],N/2+1)      ;c valeur des phases       moyennes pour chaque frequence
s11_mean   = FLTARR(s[1],s[2],N/2+1)      ;c valeur des densites     moyennes pour chaque frequence

block_mean = DCOMPLEXARR(s[1],s[2],N)     ;c valeur des coeff fft moyens pour chaque frequence
prdmax     = FLTARR(2*kb-1)
psdmax     = FLTARR(2*kb-1)
ampmax     = FLTARR(2*kb-1)

;Windowing 
hanning_coef   = SQRT(8./3.) 
hanning_window = hanning_coef*HANNING(N)

time=systime(1)
FOR I=1,2*kb-1 DO BEGIN
  decal      = I*N/2
  block      = z[*,*,decal-N/2:decal+N/2-1]
  t_block    = t[decal-N/2:decal+N/2-1]
  block      = trend_matrix(block,t_block,/remove)          ;c on enleve la tendance du bloc
;  psl_prd    = TOTAL((block*block))/N
  block      = op_matrix(block,FCT=hanning_window)          ;c on multiplie par une "window"  
  block_fft  = FFT(block,-1,/DOUBLE,DIMENSION=3)            ;c on calcul la FFT du bloc apres son "windowing"  
  block_mean = cumul_matrix(block_mean,block_fft)           ;c on calcul les valeurs de la fft pour la moyenne                  

; Calcul de la densite spectral de puissance PSD ainsi que des amplitudes et phase pour chaque onde : Y_k=A_k*exp[i*Theta_k]  
  s11      = op_cmatrix(block_fft,/s11)                         ;c densite spectrale : S11_k = 2 * Y_k * Y_k' (avec y_k'=co,jude de Y_k)
  amp      = op_cmatrix(block_fft,/amp)                         ;c amplitude         : A_k
  pha      = op_cmatrix(block_fft,/pha)                         ;c phase             : Theta_k
  psd_mean = cumul_matrix(psd_mean,s11)                         ;c c'est d'apres le cours de Klaus la puissance moyenne du signal
                                                                  ;c integree sur la bande de frequence 
                                                                  ;c == integrale de la dse sur la bande de frequence
  amp_mean = cumul_matrix(amp_mean,amp)                         ;c cumul des amp pour le calcul de la moyenne
  pha_mean = cumul_matrix(pha_mean,pha)                         ;c cumul des pha pour le calcul de la moyenne
  s11_mean = cumul_matrix(s11_mean,s11)                         ;c cumul des s11 pour le calcul de la moyenne
                                                                

;max_amp   = MAX(amp  ,MIN=min_amp)
;max_pha   = MAX(pha  ,MIN=min_pha)
;max_psd   = MAX(s11  ,MIN=min_psd)
;psl_frq   = TOTAL(s11)
;imax      = WHERE(amp EQ max_amp)
;prdmax[I-1] = prd[imax] 
;psdmax[I-1] = s11[imax]
;ampmax[I-1] = amp[imax] 
print,'***************BLOCK',strcompress(I,/REMOVE_ALL),'**********************************'
ENDFOR
print,"Time for computing blocks",systime(1)-time

psd_mean   = psd_mean/(2*kb-1)
amp_mean   = amp_mean/(2*kb-1)
pha_mean   = pha_mean/(2*kb-1)
s11_mean   = s11_mean/(2*kb-1)
block_mean = block_mean/(2*kb-1)

;
;time=systime(1)
;zfiltered = FLOAT(FFT(z,1,DIMENSION=3))
;print,"Time for inverse FFT",systime(1)-time
;
;

END