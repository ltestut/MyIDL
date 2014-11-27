demerliac    = fltarr(71)
demerliac = [1.,3.,8.,15.,21.,32.,45.,55.,72.,91.,105.,128.,153.,171., $
              200.,231.,253.,288.,325.,351.,392.,435.,465.,512.,558., $
              586.,624.,658.,678.,704.,726.,738.,752.,762.,766.,768., $
              766.,762.,752.,738.,726.,704.,678.,658.,624.,586.,558., $
	      512.,465.,435.,392.,351.,325.,288.,253.,231.,200.,171., $
	      153.,128.,105.,91.,72.,55.,45.,32.,21.,15.,8.,3.,1.]
nmj=[1.,1.,1.,1.,1.,1.,2.,2.,2.,2.,2.,2.,3.,3.,3.,3.,3.,3.,3.,3.,3.,3., $
3.,3.,2.,2.,2.,2.,2.,2.,1.,1.,1.,1.,1.,1.]
coef_demerl = intarr(4)
coef_demerl = [6,3,9]
s_nmj=0.
FOR I=0,n_elements(nmj)-1 DO BEGIN
s_nmj=s_nmj+nmj(I)
END
nmj=nmj/s_nmj
print,s_nmj
fm=[0.,0.]
F=(FINDGEN(8760)+1)/(8760.*2.)

W=2.*!PI*F
T_ech  = 3.
FN     = 1./(2.*T_ech)
thigh  = 6.
xlow   = (2.*T_ech)/thigh
tlow   = 32.
xhigh  = (2.*T_ech)/tlow
Flow   = xlow    
Fhigh  = xhigh   
Coeff  = DIGITAL_FILTER(Flow, Fhigh, 50., 71)

	
s_mxh=0.
N=10
mxh=fltarr(N)
; MOYENNE SUR X Heures = Fenetre glissante
FOR I=0,N-1 DO BEGIN
mxh(I)=1.
s_mxh=s_mxh+mxh(I)
END
mxh=mxh/s_mxh
     
ft_mxh=(sin(N*w/2.)/sin(w/2.))
ft_mxh=ft_mxh/s_mxh

; FILTRE DE EYRIES (Niveau Moyen Journalier)
ft_nmj=(sin(12.*w)/sin(w/2.))*(sin(9.*w)/sin(3.*w))


; FILTRE DE DEMERLIAC
; Calcul de Nn
Niv       = fltarr(2*(12+12)+1)
; Calcul de Ho
Niv(0:12) = Niv(0:12) + [1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,0.5]
; Calcul de N12
Niv(0:24) = Niv(0:24) + [3.,3.,3.,3.,3.,3.,3.,3.,3.,3.,3.,3.,2. $
                         ,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,0.5]
FOR J=0,2 DO BEGIN
	N = coef_demerl(J)
	print,'N   = ',N
	print,'NIV = ',Niv
	Niv(0:12-N-1)    = 2.+1. +1.   + Niv(0:12-N-1)
	Niv(12-N)        = 2.+0.5+1.   + Niv(12-N)
	Niv(12-N+1:12-1) = 2.+0. +1.   + Niv(12-N+1:12-1)
	Niv(12)          = 1.+0. +1.   + Niv(12)
	Niv(12+1:12+N-1) = 0.+0. +1.   + Niv(12+1:12+N-1)
	Niv(12+N)        = 0.+0. +0.5  + Niv(12+N)
END
; Ajout de N0.5
Niv(0:14)=Niv(0:14)+[8.,8.,8.,8.,8.,8.,8.,8.,8.,8.,7.5,6.5,4.,1.5,0.5]
;Nivtot = fltarr(2*(12+12)+1)
Nivtot=[REVERSE(Niv[1:2*(12+12)]),Niv(0),Niv[1:2*(12+12)]]
s_nivtot=0.
FOR I=0,n_elements(nivtot)-1 DO BEGIN
s_nivtot=s_nivtot+nivtot(I)
END
nivtot=nivtot/s_nivtot
nivtot=nivtot[where(nivtot gt 0.)]


s_demerliac=0.
ft_demerliac=0.
FOR I=0,70 DO BEGIN
s_demerliac=s_demerliac+demerliac(I)
END
demerliac=demerliac/s_demerliac
     
FOR I=35,70 DO BEGIN
ft_demerliac=ft_demerliac+2*demerliac(I)*cos((I-35)*w)
END     
ft_demerliac=ft_demerliac	

; FILTRE DE ROSSITER
ft_rossiter=cos(3.*w/2.)*cos(3*w)*cos(9.*w/2.)*cos(6.*w)
ft_rossiter2=(2.+4.*(cos(3.*w)+cos(6.*w))+2.*(cos(9.*w)+cos(12.*w)+cos(15.*w)))/16.

; FILTRE DE DOODSON
ft_doodson=(sin(12.*w)/sin(4.*w))*(sin(12.5*w)/(2.5*w))*(2*cos(w))/30.

; FILTRE DE LANCZOS
M=4
lanczos=fltarr(2*M+1)
FOR K=1,M DO BEGIN
COEF=(sin(!PI*FLOAT(K)/FLOAT(M))/(!PI*FLOAT(K)/FLOAT(M)))
lanczos(K)=(WC/WN)*COEF*(sin(!PI*FLOAT(K)*WC/WN)/(!PI*FLOAT(K)*WC/WN))
;print,'K= ',k,'  COEF=',coef,'LANCZOS=   ',lanczos(k)
END
;print,lanczos
;print,REVERSE(lanczos)
lanczos=[REVERSE(lanczos[1:M]),WC/WN,lanczos[1:M]]
END
