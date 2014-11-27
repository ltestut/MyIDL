PRO gsaison,x,A,yfit,pder
;; F(x)= Af*cos(2pif.X)+Bf*sin(2pif.X)
;; A[0]=Af
;; A[1]=Bf

n_var = N_ELEMENTS(A)/2
m     = N_ELEMENTS(x)
yfit  = fltarr(m)

print,'nombre de frequence prise en compte',n_var
print,'nombre de points pris en compte    ',m
help,x,yfit

dpi=2*!PI

;c RECONSTRUCTION DU SIGNAL SUR A PARTIR DES PERIODES (J) CI-DESSOUS
onde  = [365.]
;;onde = [8760.]
;;onde8= [M2,S2,N2,K1,K2,O1,2N2,Q1]
;;------------------------------------------------------------

freq=onde     ;;periodes a prendre en compte pour la reconstruction du signal
fmar=1./freq   ;;frequences associées
help,fmar
;c construction de la fonction F(x)= somme/freq [Af*cos(2pif.X)+Bf*sin(2pif.X)]
FOR I=0,n_var-1 DO BEGIN
yfit = yfit + $
    A[2*I]*cos(dpi*fmar[I]*x)+A[2*I+1]*sin(dpi*fmar[I]*x)  ;+ A[2*I+2]
END


;c calcul des derivees par rapport aux coefficients Ai te Bi
IF N_PARAMS() GE 4 THEN $
pder  = fltarr(m,n_var)
;;pder  =[[cos(dpi*fmar[0]*x)],[sin(dpi*fmar[0]*x)],[replicate(1.,n_elements(x))]]
pder  =[[cos(dpi*fmar[0]*x)],[sin(dpi*fmar[0]*x)]]

FOR I=1,n_var-1 DO BEGIN
;;pder=[[pder],[cos(dpi*fmar[I]*x)],[sin(dpi*fmar[I]*x)],[replicate(1.,n_elements(x))]]
pder=[[pder],[cos(dpi*fmar[I]*x)],[sin(dpi*fmar[I]*x)]]
END
END
