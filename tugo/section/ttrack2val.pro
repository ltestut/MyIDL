FUNCTION ttrack2val, track
; function qui permet de calculer une formule a partir d'un section de type ttrack


npt   = N_ELEMENTS(track.pt.lon)
nt    = N_ELEMENTS(track.pt[0].u)

rho = 1025.0 ;densite moyenne de l'eau de mer kg/m3
h   = 400.

FOR i=0,npt-1 DO BEGIN
 ;calcul de la force de pression par unite de surface en Pa
 track.pt[i].val=rho*h*(SQRT(track.pt[i].u*track.pt[i].u+track.pt[i].v*track.pt[i].v)*$
                  SQRT(track.pt[i].u*track.pt[i].u+track.pt[i].v*track.pt[i].v))/(2.)  
                  
ENDFOR
RETURN,track
END