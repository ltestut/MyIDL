FUNCTION s11_cmatrix, Z
;Z_out = 2*(Z[*,*,0:N/2]*CONJ(Z[*,*,0:N/2]))
s      = SIZE(Z)
Z_out  = FLTARR(s(1),s(2),(s(3)/2+1)) 
FOR I=0,s[3]/2 DO Z_out[INDGEN(s[1]),INDGEN(s[2]),I] = 2*Z[INDGEN(s[1]),INDGEN(s[2]),I]*CONJ(Z[INDGEN(s[1]),INDGEN(s[2]),I])
RETURN,Z_out
END
