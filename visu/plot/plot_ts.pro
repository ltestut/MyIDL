; $Id: plot_ts.pro,v 1.00 21/10/2005 L. Testut $
;

;+
; NAME:
;	PLOT_TS
;
; PURPOSE:
;	Plot the Temperature-Salinity diagram of a ctd_oiso structure 
;  
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	plot_ts,st 
;	
;
; INPUTS:
;	st  : structure of type {info:'', name:'', jul:'',coord:FLTARR(2), depth:0.0, temp:0.0, sal:0.0, theta:0.0, sigma:0.0}
;
; OUTPUTS:
;	plot on X window
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
; 
;-
;

PRO plot_ts, st, _EXTRA=extra, srange=srange, trange=trange

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  plot_ts,st (structure of type oiso)'
;Compute the density function for standard values of T and S
sal  = 30.+ FINDGEN(101)*0.1
temp = 0. + FINDGEN(101)*0.3
p0   = FLTARR(101,101)
a1   = FLTARR(101,101)
r    = FLTARR(101,101)


X=[34.9,35.,35.,34.9]
Y=[2.,2.,4.,4.] 
; Compute the density in (kg/l) from temperature and salinity
FOR I=0,100 DO p0[I,*]  = 5890. + 38.*temp - 0.375*temp*temp + 3.*sal[I]
FOR I=0,100 DO a1[I,*]  = 1779.5 + 11.25*temp - 0.0745*temp*temp - (3.8 + 0.01*temp)*sal[I]
a0  = 0.6980
r   = ((p0/(a1 + a0*p0))*1000.-1000.)

IF NOT KEYWORD_SET(srange) THEN srange=[MIN(sal),MAX(sal)] 
IF NOT KEYWORD_SET(trange) THEN trange=[MIN(temp),MAX(temp)] 

CONTOUR,r,sal,temp,NLEVELS=20,/FOLLOW,$
       TITLE='Diagram T-S',XTITLE='Salinity',YTITLE='Temperature',$ 
       XRANGE=srange,YRANGE=trange,$
       C_LINESTYLE=1

POLYFILL,X,Y,COLOR=150

OPLOT,st.sal,st.temp,psym=1

END
