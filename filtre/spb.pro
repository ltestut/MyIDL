PRO spb, st, DT=DT, NB=NB 

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:'
 print, 'Spectre par bloc pour une serie reguliere de type {jul,val}'
 print, 'spb, st, DT=DT, NB=NB'
 print, ''
 print, "INPUT : st          --> structure de type {jul.val}"
 print, "INPUT : DT          --> echantillonnage en heure [defaut=24]"
 print, "INPUT : NB          --> nombre de bloc [defaut=4]"
 print, 'OUTPUT: place/rapport_alti_tr(xxx).ps'
 RETURN
ENDIF


IF n_elements(DT) EQ 0 THEN DT = 24.
IF n_elements(NB) EQ 0 THEN NB = 4

;;block averaging
print,'**************BLOCK AVERAGING***********'
n_block= NB
delt   = DT ;; en heures
t_block= n_elements(st)/n_block
print,'Nombre de donnees de la serie',n_elements(st)
print,'Nombre de block choisies',n_block
print,'Taille des blocks',t_block
print,'DOF =',2*n_block
duree_block       = FLOAT(t_block)*FLOAT(delt)/24. 
freq_ech          = 1./delt
pas_freq_block    = freq_ech/FLOAT(t_block)
temps_block       = delt/24.* FINDGEN(t_block)  ;temps en heures

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

	block      = st[decal-t_block/2:decal+t_block/2-1].val
	block      = block - MEAN(block,/NAN)
        iz         = where(FINITE(block) EQ 0,count)
	if (count gt 0) then block[iz]    = 0.
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
;print,'***********************BLOCK 1**********************************'
;print, 'BLOCK1_Amplitude :  Max=', max_ampl, '  Min=', min_ampl,' -->  S11 : ',max_ampls,min_ampls
;print, 'BLOCK1_Phase     :  Max=', max_pha, '  Min=', min_pha ,' -->  S11 : ',max_phas,min_phas
;print, 'BLOCK1_Dse       :  Max=', max_ampl^2, '  Min=', min_ampl^2 ,' -->  S11 : ',max_dse,min_dse
ENDFOR
dseblock  = dseblock /(2*n_block-1)
s11       = s11/(2*n_block-1)



max_dseb = MAX(dseblock       ,MIN=min_dseb)
max_dse  = MAX(ABS(s11)       ,MIN=min_dse)
print, 'Dse  after block average: Max=', max_dseb, '  Min=', min_dseb,' -->  S11 : ',max_dse,min_dse


;;!P.MULTI=[0,1,1]

;; POUR IMPRIMER DANS UN FICHIER PS
;; Enregistrement de la device d'origine
;;loadct,2
;;set_plot, 'X'
;;device, /portrait, /color, filename='plot.ps', /narrow, font_size=10, xsize=18, $
;;        ysize=22,xoffset=2.,yoffset=4.


color1=50
;color2=100

;PLOT N°1
PLOT, period_block, abs(s11), /xlog , /ylog, $
title='SPECTRA', subtitle='', xtitle='', ytitle='DSE in cm^2/cph',$
xticks=5,xtickv=[35040,8760,730,168,24,12],xticklen=1.,xtickname=['4y','year','month','week','24','12'],yrange=[0.00001,1000],ystyle=1,xstyle=1,xrange=[2,40000],$
ygridstyle=1,yticklen=1

;;device, /close_file
END
