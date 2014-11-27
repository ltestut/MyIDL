PRO coherence_st_dvp, st1, st2, kb=kb

IF (N_PARAMS() EQ 0) THEN BEGIN
	print, 'UTILISATION:'
	print, 'plot_coherence_st, st1, st2, kb=kblock'
	print, ''
	print, 'INPUT:  st1,st2  --> de types {jul,val}'
	print, 'INPUT:  kblock   --> Nbr de block pour le calcul des (choisir un multiple de 2)'
	print, 'OUTPUT: *.ps       --> de type {frq,prd,psd,fft}'
RETURN
ENDIF

IF (N_ELEMENTS(kb) EQ 0) THEN kb=1
nmin = N_ELEMENTS(st1)
IF (N_ELEMENTS(st2) LT nmin) THEN nmin=N_ELEMENTS(st2)

fft_st_dvp,st1,sf1,kb=kb,Nexct=nmin
fft_st_dvp,st2,sf2,kb=kb,Nexct=nmin

s11 = 2*sf1.fft*CONJ(sf1.fft) ;c psd moyenne sur la bande de frenquence (x2 pour la symetrie)
s22 = 2*sf2.fft*CONJ(sf2.fft)
s12 = 2*sf1.fft*CONJ(sf2.fft) ;c cross-spectrum (inverse FFT de la fct de covariance)

sqcoherence = ABS(s12)^2/(s11*s22) ;c squared coherence spectrum
help, sqcoherence
print,'*********COHERENCE*************'
max_sco  = MAX(sqcoherence           ,MIN=min_sco)
max_pha  = MAX(IMAGINARY(sqcoherence),MIN=min_pha)
print, 'Squared Coherence : Max=', max_sco, '  Min=', min_sco  ;,' -->  amp,pha (coh) : ',max_coh,max_pha

alpha = 0.01 ;0.01=99%  
edof  = 2*float(kb)  ;n_block) 
ccl   = 1.-alpha^(1./(edof-1.)) 
print,'99% of confidence level =',ccl

print,'*******TRANSFERT FUNCTION'
trsf  = s12/s11
trsf2  = s12/s22
;trsf3  = s32/s22

loadct,3
!P.MULTI=[0,1,1]

IF (N_ELEMENTS(title) EQ 1) THEN BEGIN
 original_device= !D.NAME
 set_plot, 'PS'
 !P.FONT= 0
 output = STRING(strcompress(title,/REMOVE_ALL),'.plot_coherence.ps')
 device, /portrait, /color, filename=output, $
         /narrow, font_size=10,$
         xsize=18, ysize=22,xoffset=2.,yoffset=4.
ENDIF ELSE BEGIN
 set_plot, 'X'
 device, retain=2, decomposed=0
 output='Xwindow'
 window, title='FFT'
ENDELSE



;PLOT N°1
x=findgen(2000)+100
PLOT, x, tab(x), title='BOTTOM PRESSURE, SEA LEVEL AND INVERSE BAROMETER AT KERGUELEN 1991', subtitle='', xtitle='time in hours', ytitle='Sea level equivalent in cm'
OPLOT,x, tab2(x) ,color=85,thick=3
OPLOT,x, tab3(x) ,thick=0.5,linestyle=1
;XYOUTS,200,30, ' RES  [rms=12.4 cm]   '
;OPLOT, [600,900], [30,30]
;XYOUTS,200,20, ' IBARO = -CBARO  [rms=11.99 cm]'
;OPLOT, [600,900], [20,20], color = 25,thick=5
;XYOUTS,200,100, ' RES   = SLEV-PREdiction       [rms=12.4 cm]'
;OPLOT, [1600,1900], [100,100], color = 85,thick=3

PLOT, period_block, abs(s11), /xlog, /ylog ,$
title='SPECTRA', subtitle='', xtitle='', ytitle='DSE in cm^2/cph',$
xticks=5,xtickv=[35040,8760,730,168,24,12],xticklen=1.,xtickname=['4y','year','month','week','24','12'],yrange=[0.00001,1000],ystyle=1,xstyle=1,xrange=[2,40000]
OPLOT,period_block, abs(s22),color=85
OPLOT,period_block, abs(s33),thick=0.5,linestyle=1
XYOUTS,13,exp(4.), ' SLEV=BOT-CBARO  [rms=36.11 cm] N=2800, N_block=4 ',CHARSIZE=0.4
OPLOT, [1000,8760], [exp(4.),exp(4.)]
XYOUTS,13,exp(3.), ' IBARO = -CBARO  [rms=12.53 mb]',CHARSIZE=0.4
OPLOT, [1000,8760], [exp(3.),exp(3.)], color = 85
XYOUTS,13,exp(2.), ' BOT     [rms=35.13  mb]',CHARSIZE=0.4
OPLOT, [1000,8760], [exp(2.),exp(2.)], linestyle=1
;PLOT N°2
PLOT, period_block, abs(coherency), /xlog, $
title='SQUARED COHERENCE', subtitle='', xtitle='', ytitle='COHERENCE', yrange=[0,1.2],$
yticks=1,ytickv=[ccl,1.],yticklen=0.5,ytickname=['99%','1'],$
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']
oplot,period_block, abs(coherency2),linestyle=1

;PLOT N°3
PLOT, period_block, IMAGINARY(coherence)*180./!pi, /xlog, $
title='DEPHASAGE', subtitle='', xtitle='', ytitle='PHASE en degre',$
;yrange=[-180,180]
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']
OPLOT, period_block, IMAGINARY(coherence2)*180./!pi,linestyle=1

;PLOT N°1
PLOT, period_block, ABS(trsf2), thick=1, /xlog , yrange=[0,2.5] ,LINESTYLE=0,$
title='ADMITTANCE FUNCTION BETWEEN SLEV AND CBARO, BOT and CBARO', subtitle='', xtitle='Period in hours', ytitle='Admittance amplitude in mbar/cm',$
xticks=9,xtickv=[8760,6*720,20*24,10*24,6*24,4*24,3*24,24*2,24,12],xticklen=1.,xtickname=['year','6month','20d','10d','6d','4d','3d','2d','24','12']
;yticks=0,ytickv=[ccl],yticklen=0.5,ytickname=['99%']
;xticks=8,xtickv=[8760,730,168,24,12,8,6,4,3],xticklen=1.,xtickname=['year','month','week','24','12','8','6','4','3']
OPLOT,period_block, ABS(trsf3),linestyle=1
OPLOT,period_block, ABS(trsf2)+ABS(trsf3),thick=0.2,color=100,linestyle=2

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
oplot,period_block, IMAGINARY(trsf3)*180./!pi,linestyle=1

device, /close_file


;device, /close_file
END
