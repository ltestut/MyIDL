FUNCTION flag_matrix3d,H,_EXTRA=_EXTRA
; permete de flagger une matrice 3D au dessus ou en dessous d'un certain seuil
s     = SIZE(H)
ntime = s[3]

FOR I=0,ntime-1 DO BEGIN
   H[*,*,I]=flag_matrix(H[*,*,I],_EXTRA=_EXTRA)
ENDFOR
RETURN, H
END