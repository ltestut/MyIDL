 PRO cpb, st1, st2, DT=DT, NB=NB, place=place, T1=T1, T2=T2

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:'
 print, 'Coherence par bloc pour deux serie reguliere de type {jul,val}'
 print, 'cpb, st1, st2, DT=DT, NB=NB, place=place'
 print, ''
 print, "INPUT : st,st2      --> structures de type {jul.val}"
 print, "INPUT : DT          --> echantillonnage en heure [defaut=24]"
 print, "INPUT : NB          --> nombre de bloc [defaut=4]"
 print, "INPUT : place       --> where to place the ouptut"
 print, 'OUTPUT: place/coherence.ps' 
 RETURN
ENDIF

IF n_elements(DT) EQ 0 THEN DT = 24.
IF n_elements(NB) EQ 0 THEN NB = 4
IF n_elements(place) EQ 0 THEN place = '~/'
IF n_elements(T1) EQ 0 THEN T1= 'serie n°1'
IF n_elements(T2) EQ 0 THEN T2= 'serie n°2'
output    = STRING(place,'coherence','.ps')

;;block averaging
print,'**************BLOCK AVERAGING***********'
n_block= NB
delt   = DT ;; en heures
ND     = N_ELEMENTS(st1)
if (N_ELEMENTS(st1) GE N_ELEMENTS(st2)) then ND=N_ELEMENTS(st2)
t_block=ND/n_block

print,'Nombre de donnees de la serie 1 ',n_elements(st1)
print,'Nombre de donnees de la serie 2 ',n_elements(st2)
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
dse2block   = fltarr(t_block/2+1)

s11         = dcomplexarr(t_block/2+1)
s22         = dcomplexarr(t_block/2+1)
s12         = dcomplexarr(t_block/2+1)

FOR I=1,2*n_block-1 DO BEGIN
	decal      = I*t_block/2


	block      = st1[decal-t_block/2:decal+t_block/2-1].val
	block      = block - MEAN(block,/NAN)
        iz         = where(FINITE(block) EQ 0,count)
	if (count gt 0) then block[iz]    = 0.

	block2      = st2[decal-t_block/2:decal+t_block/2-1].val
	block2      = block2 - MEAN(block2,/NAN)
        iz          = where(FINITE(block2) EQ 0,count2)
	if (count2 gt 0) then block2[iz]    = 0.
	
	block_fft  = FFT(1.632993162*HANNING(N_ELEMENTS(block))*block,/DOUBLE)
	block2_fft = FFT(1.632993162*HANNING(N_ELEMENTS(block2))*block2,/DOUBLE)

	
	amp_block  = ABS(block_fft(0:t_block/2))
	pha_block  = ATAN(block_fft(0:t_block/2))
	sblock11   = delt*block_fft(0:t_block/2)*CONJ(block_fft(0:t_block/2))

	amp_block2 = ABS(block2_fft(0:t_block/2))
	pha_block2 = ATAN(block2_fft(0:t_block/2))
	sblock22   = delt*block2_fft(0:t_block/2)*CONJ(block2_fft(0:t_block/2))
	
 cross_block = delt*CONJ(block_fft(0:t_block/2))*block2_fft(0:t_block/2)
 
	dseblock   = dseblock  + amp_block^2
	s11        = s11       + sblock11
	dse2block  = dse2block + amp_block2^2
	s22        = s22       + sblock22
	
	s12        = s12       + cross_block
	

max_ampl   = MAX(amp_block        ,MIN=min_ampl)
max_ampls  = MAX(SQRT(ABS(s11/I)) ,MIN=min_ampls)
max_pha    = MAX(pha_block        ,MIN=min_pha)
max_phas   = MAX(IMAGINARY(s11/I) ,MIN=min_phas)
max_dse    = MAX(ABS(s11/I)       ,MIN=min_dse)
;print,'***********************BLOCK 1**********************************'
;print, 'BLOCK1_Amplitude :  Max=', max_ampl, '  Min=', min_ampl,' -->  S11 : ',max_ampls,min_ampls
;print, 'BLOCK1_Phase     :  Max=', max_pha, '  Min=', min_pha ,' -->  S11 : ',max_phas,min_phas
;print, 'BLOCK1_Dse       :  Max=', max_ampl^2, '  Min=', min_ampl^2 ,' -->  S11 : ',max_dse,min_dse
max_ampl   = MAX(amp_block2       ,MIN=min_ampl)
max_ampls  = MAX(SQRT(ABS(s22/I)) ,MIN=min_ampls)
max_pha    = MAX(pha_block2       ,MIN=min_pha)
max_phas   = MAX(IMAGINARY(s22/I) ,MIN=min_phas)
max_dse    = MAX(ABS(s22/I)       ,MIN=min_dse)
;print,'***********************BLOCK 2**********************************'
;print, 'BLOCK2_Amplitude :  Max=', max_ampl, '  Min=', min_ampl,' -->  S22 : ',max_ampls,min_ampls
;print, 'BLOCK2_Phase     :  Max=', max_pha, '  Min=', min_pha ,' -->  S22 : ',max_phas,min_phas
;print, 'BLOCK2_Dse       :  Max=', max_ampl^2, '  Min=', min_ampl^2 ,' -->  S22 : ',max_dse,min_dse
ENDFOR

dseblock  = dseblock /(2*n_block-1)
s11       = s11/(2*n_block-1)
dse2block = dse2block/(2*n_block-1)
s22       = s22/(2*n_block-1)


s12       = s12 /(2*n_block-1)
coherence = (s12)^2/(s11*s22)
coherency = ABS(s12)^2/(s11*s22)

help,coherence,coherency

max_dseb = MAX(dseblock       ,MIN=min_dseb)
max_dse  = MAX(ABS(s11)       ,MIN=min_dse)
print, 'Dse  after block average: Max=', max_dseb, '  Min=', min_dseb,' -->  S11 : ',max_dse,min_dse
max_dseb = MAX(dse2block      ,MIN=min_dseb)
max_dse  = MAX(ABS(s22)       ,MIN=min_dse)
;print, 'Dse2 after block average: Max=', max_dseb, '  Min=', min_dseb,' -->  S22 : ',max_dse,min_dse

print,'*********COHERENCE*************'
max_co   = MAX(coherency            ,MIN=min_co)
max_coh  = MAX(ABS(coherence)       ,MIN=min_co)
max_pha  = MAX(IMAGINARY(coherence) ,MIN=min_pha)
print, 'Coherence : Max=', max_co, '  Min=', min_co,' -->  amp,pha (coh) : ',max_coh,max_pha

alpha = 0.01 ;0.01=99%  
edof  = 2*float(n_block) 
ccl   = 1.-alpha^(1./(edof-1.)) 
print,'99% of confidence level =',ccl

print,'*******TRANSFERT FUNCTION'
trsf  = s12/s11
trsf2  = s12/s22


!P.MULTI=[0,2,3]

; POUR IMPRIMER DANS UN FICHIER PS
; Enregistrement de la device d'origine
loadct,2
!P.FONT=2
set_plot, 'PS'
device, /portrait, /color, filename=output, /narrow, font_size=10, xsize=18, $
        ysize=22,xoffset=2.,yoffset=4.


th=3
col2=85


xrmin=JULDAY(1,1,1996)
xrmax=JULDAY(5,1,1996)
yrmin=[MIN(st1.val,MAX=yr1,/NAN),MIN(st2.val,MAX=yr2,/NAN)]
yrmax=[yr1,yr2]
date_label= LABEL_DATE(DATE_FORMAT = ['%M','%Y'])

PLOT, st1.jul, st1.val-MEAN(st1.val,/NAN), title='KERGUELEN', subtitle='', xtitle='', ytitle='SLA (cm)',$
        XRANGE=[xrmin,xrmax],YRANGE=[-20,20],$
	XSTYLE=1,YSTYLE=1,THICK=th,$
        XTICKFORMAT   = ['LABEL_DATE','LABEL_DATE'],$
	XTICKUNITS    = ['Months','Year'],$                
	XTICKINTERVAL = 6  ,$ 
	XTICKLEN      = 0.1,$
	XTICKLAYOUT   = 2
OPLOT,st2.jul, st2.val-MEAN(st2.val,/NAN) ,color=col2,thick=th
textinfo = [T1,T2]
xinfo    = REPLICATE(13,N_ELEMENTS(textinfo))
yinfo    = yrmax-FINDGEN(N_ELEMENTS(textinfo))
colorinfo= [0,col2]
XYOUTS,xinfo,yinfo,textinfo,color=colorinfo,CHARSIZE=15.2,/NORMAL



PLOT, period_block, abs(s11), /xlog,$
title='SPECTRA', subtitle='', xtitle='', ytitle='DSE in cm^2/cph',$
xticks=5,xtickv=[35040,8760,730,168,24,12],xticklen=1.,xtickname=['4y','year','month','week','24','12'],yrange=[0,4],ystyle=1,xstyle=1,xrange=[2,40000]
OPLOT,period_block, abs(s22),color=85



textinfo = [T1,T2]
xinfo    = REPLICATE(13,N_ELEMENTS(textinfo))
yinfo    = exp(4.-FINDGEN(N_ELEMENTS(textinfo)))
;;colorinfo= INDGEN(N_ELEMENTS(textinfo))*5
XYOUTS,xinfo,yinfo,textinfo,CHARSIZE=1.2,/NORMAL











XYOUTS,13,exp(4.), ' SLEV=BOT-CBARO  [rms=36.11 cm] N=2800, N_block=4 ',CHARSIZE=0.4
OPLOT, [1000,8760], [exp(4.),exp(4.)]
XYOUTS,13,exp(3.), ' IBARO = -CBARO  [rms=12.53 mb]',CHARSIZE=0.4
OPLOT, [1000,8760], [exp(3.),exp(3.)], color = 85

;PLOT N°2
PLOT, period_block, abs(coherency), /xlog, $
title='SQUARED COHERENCE', subtitle='', xtitle='', ytitle='COHERENCE', yrange=[0,1.2],$
yticks=1,ytickv=[ccl,1.],yticklen=0.5,ytickname=['99%','1'],$
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']

;PLOT N°3
PLOT, period_block, IMAGINARY(coherence)*180./!pi, /xlog, $
title='DEPHASAGE', subtitle='', xtitle='', ytitle='PHASE en degre',$
;yrange=[-180,180]
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']

;PLOT N°1
PLOT, period_block, ABS(trsf2), thick=1, /xlog , yrange=[0,2.5] ,LINESTYLE=0,$
title='ADMITTANCE FUNCTION BETWEEN SLEV AND CBARO, BOT and CBARO', subtitle='', xtitle='Period in hours', ytitle='Admittance amplitude in mbar/cm',$
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']
;yticks=0,ytickv=[ccl],yticklen=0.5,ytickname=['99%']
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']

;XYOUTS,740,exp(4.3), ' CBARO DATA SERIE    '
;XYOUTS,740,exp(3.9), ' Ndata      = 70752  '
;XYOUTS,740,exp(3.5), ' Ngaps      =   433  '
;XYOUTS,740,exp(3.1), ' Filled gaps =    0  '
;XYOUTS,740,exp(2.7), ' Mean       =     0  '
;XYOUTS,740,exp(2.3), ' Rms        =    12  '
;XYOUTS,740,exp(1.5), ' BLOCK AVERAGING        '
;XYOUTS,740,exp(1.1), ' N_block    =    20      '
;XYOUTS,740,exp(0.7), ' Block size =  3537      '
;XYOUTS,740,exp(0.3), ' Dof        =    40      '
;OPLOT,period_block, Fq_block*s11 ,thick=3   ,color=85
;OPLOT,period_block, Fq_block*(s22)    ,color=25

;PLOT N°3
PLOT, period_block, IMAGINARY(trsf2)*180./!pi, /xlog, $
title='DEPHASAGE', subtitle='', xtitle='', ytitle='PHASE en degre',$
yrange=[-80,80],$
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']

device, /close_file
print,'OUTPUT=',output


END
