PRO coherence_julval, sta, stb, sco, kb=kb

IF (N_PARAMS() EQ 0) THEN BEGIN
	print, 'UTILISATION:'
	print, 'coherence_julval, st1, st2, kb=kblock'
	print, ''
	print, 'INPUT :  st1,st2  --> de types {jul,val}'
	print, 'INPUT :  kb       --> Nbr de block pour le calcul des (choisir un multiple de 2)'
	print, 'OUTPUT:  sco      --> de type {frq, prd, co2, edof, ccl}'

RETURN
ENDIF

IF (N_ELEMENTS(kb) EQ 0) THEN kb=5

; on synchronize les donnees
synchro_julval,sta,stb,st1,st2,bs=10.

fft_julval,st1,sf1,kb=kb
fft_julval,st2,sf2,kb=kb

s11    = sf1.psd
s22    = sf2.psd
s12    = 2*sf1.fft*CONJ(sf2.fft) ;c cross-spectrum (inverse FFT de la fct de covariance)
scoher = ABS(s12)^2/(s11*s22)    ;c squared coherence spectrum

print,'*********COHERENCE*************'
max_sco  = MAX(scoher       ,MIN=min_sco)
max_pha  = MAX(IMAGINARY(scoher),MIN=min_pha)
print, 'Squared Coherence : Max=', max_sco, '  Min=', min_sco  ;,' -->  amp,pha (coh) : ',max_coh,max_pha

alpha = 0.01 ;0.01=99%  
edof  = 2*float(kb)  ;n_block) 
ccl   = 1.-alpha^(1./(edof-1.)) 
print,'99% of confidence level =',ccl

print,'*******TRANSFERT FUNCTION'
trsf  = s12/s11
trsf2  = s12/s22
help,trsf2
N = N_ELEMENTS(scoher)

sco={frq:FLTARR(N), prd:FLTARR(N), co2:FLTARR(N), edof:0, ccl:0.}
sco.frq  =sf1.frq
sco.prd  =sf1.prd
sco.co2  =scoher
sco.edof =edof
sco.ccl  =ccl

plot,sco.prd,sco.co2, /xlog, $
title='SQUARED COHERENCE', subtitle='', xtitle='', ytitle='COHERENCE', yrange=[0,1.2],$
yticks=1,ytickv=[sco.ccl,1.],yticklen=0.5,ytickname=['99%','1']

;; Derniere Modif le 20/02/2008
END
