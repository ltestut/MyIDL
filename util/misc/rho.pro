; $Id: rho.pro,v 1.00 27/05/2005 L. Testut $
;

;+
; NAME:
;	RHO
;
; PURPOSE:
;	Compute the density from salinity en temperature
;  
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	r=RHO(sal=sal,temp=temp)
;	
;
; INPUTS:
;	sal  : Salinity in psu
;	temp : Temperature  in °C
;
; OUTPUTS:
;	rho  : Density of water in kg/l
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

FUNCTION rho, sal=sal, temp=temp

;IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  rho=rho(sal=sal,temp=temp) in kg/l'

IF NOT KEYWORD_SET(sal)    THEN sal=35.
IF NOT KEYWORD_SET(temp)   THEN temp=10.

; Compute the density in (kg/l) from temperature and salinity
p0  = 5890. + 38.*temp - 0.375*temp*temp + 3.*sal
a1  = 1779.5 + 11.25*temp - 0.0745*temp*temp - (3.8 + 0.01*temp)*sal
a0  = 0.6980
r   = p0/(a1 + a0*p0)

RETURN, r
END
