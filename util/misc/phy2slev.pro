; $Id: phy2slev.pro,v 1.00 22/05/2005 L. Testut $
;

;+
; NAME:
;	PHY2SLEV
;
; PURPOSE:
;	Compute the sea level from the phy structure 
;  
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=PHY2SLEV(phy,mto=mto,sal=sal,temp=temp)
;	
;       use the fct/proc : -> CREATE_JULVAL
;                         
; INPUTS:
;	phy : Structure of type {jul,twat,bot,baro,mto}
;
; OUTPUTS:
;	st  : Structure of type {jul,val}
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
; - Le 26/05/2005 Add the temperature choice
;-
;

FUNCTION phy2slev, phy, mto=mto, sal=sal, temp=temp

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=phy2slev(phy,sal=sal,temp=temp,/mto) in cm'

g   = 9.78049
I   = 3
t   = FLTARR(N_ELEMENTS(phy.jul))

IF NOT KEYWORD_SET(sal)    THEN sal=35.
IF NOT KEYWORD_SET(temp)   THEN t=phy.twat
IF (N_ELEMENTS(temp) NE 0) THEN t[*]=temp

IF KEYWORD_SET(mto) THEN I=4

; Compute the density in (kg/l) from temperature and salinity
p0  = 5890. + 38.*t - 0.375*t*t + 3.*sal
a1  = 1779.5 + 11.25*t - 0.0745*t*t - (3.8 + 0.01*t)*sal
a0  = 0.6980
rho = p0/(a1 + a0*p0)

; Compute the sea level from bottom pressure and atmospheric pressure
st=CREATE_JULVAL(N_ELEMENTS(phy.bot))
st.jul=phy.jul
st.val=10.*(phy.bot-phy.(I))/(rho*g)

;print,'T    = ',t[10:14]
;print,'rho  = ',rho[10:14]
;print,'slev = ',st[10:14].val

RETURN, st
END
