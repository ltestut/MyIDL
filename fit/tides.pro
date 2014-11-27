PRO tides,x,A,yfit,pder
; F(x)= Af*cos(2pif.X)+Bf*sin(2pif.X)
; A[0]=Af
; A[1]=Bf

n_var = N_ELEMENTS(A)/2
m     = N_ELEMENTS(x)
yfit  = fltarr(m)

print,'nombre de frequence prise en compte',n_var
print,'nombre de points pris en compte    ',m
help,x,yfit

dpi=2*!PI

; RECONSTRUCTION DU SIGNAL SUR A PARTIR DES PERIODES (H) CI-DESSOUS
wave12h=[13.1273,12.9054,12.8718,12.6583,12.6260,12.4206,12.2218,12.1916,12.0164,$
         12.0000,11.9836,11.9672,11.7545]
	 
wave24h=[28.0062,27.8484,26.8684,26.7231,25.8193,25.6681,24.8492,24.8332,24.7091,$
         24.1321,24.0659,24.0000,23.9345,23.8045,23.2070,23.0985,22.4202,22.3061,21.5782]

onde77=360./[13.94303558$
,14.95893134,15.04106864,27.42383374,27.89535482,27.96820844,28.43972952$
,28.51258314,28.98410422,29.45562530,29.52847892,29.95893332,30.00000000,30.08213728$
,30.54437470,31.01589578,57.42383374,57.96820844,58.98410422,59.06624150,86.40793796$
,86.95231266,87.42383374,44.02517286,42.92713980,15.00000000,13.39866088,16.13910170$
,15.58544334,29.06624150,28.90196694,28.90196694,56.87945904,43.47615633,45.00000000$
,29.02517286,28.94303558,0.54437470,1.01589578,1.09803306,0.47152108,1.64240776$
,2.18678246,1.56955414,2.11392884,0.08213728,0.04106864,16.05696442,14.02517286$
,30.04106668,27.34169646,27.42383374,43.94303558,45.04106860,58.43972952,60.00000000$
,58.05034572,56.95231266,87.96820844,88.05034572,116.95231266,27.96820844,29.52847892$
,29.45562530,27.88607116,28.51258314,12.85428620,12.92713980,13.47151450,14.56954760$
,14.91786470,15.12320590,15.51258970,14.49669390,14.48741030,16.68347640,30.62651200]

onde8=[12.42,12.,12.6576,23.9352,11.9664,25.8192,12.8712,26.868]/24.
;onde8=[M2,S2,N2,K1,K2,O1,2N2,Q1]
;------------------------------------------------------------


freq=onde77/24.   ;periodes a prendre en compte pour la reconstruction du signal
fmar=1/freq   ;frequences associ�es


; construction de la fonction F(x)= somme/freq [Af*cos(2pif.X)+Bf*sin(2pif.X)]
FOR I=0,n_var-1 DO BEGIN
yfit = yfit + A[2*I]*cos(dpi*fmar[I]*x)+A[2*I+1]*sin(dpi*fmar[I]*x)
END


; calcul des derivees par rapport aux coefficients Ai te Bi
IF N_PARAMS() GE 4 THEN $
pder  = fltarr(m,n_var)
pder  =[[cos(dpi*fmar[0]*x)],[sin(dpi*fmar[0]*x)]]

FOR I=1,n_var-1 DO BEGIN
pder=[[pder],[cos(dpi*fmar[I]*x)],[sin(dpi*fmar[I]*x)]]
END
END