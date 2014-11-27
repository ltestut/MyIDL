FUNCTION gradient_matrix, Z, Zx, Zy, D=D
;compute the gradient of a matrix
; Z    : input matrix
; Zx   : output DZ/Dx matrix
; Zy   : output DZ/Dy matrix
; D=-1 : grid separation to compute the gradient
; Zout : RETURN the magnitude of the slope
IF NOT KEYWORD_SET(D) THEN D=-1
s      = SIZE(Z)
Zx     = Z 
Zy     = Z 
Zout   = Z 
FOR I=0,s[3]-1 DO BEGIN
 Zx[INDGEN(s[1]),INDGEN(s[2]),I]   = SHIFT(Z[INDGEN(s[1]),INDGEN(s[2]),I],[D,0])-Z[INDGEN(s[1]),INDGEN(s[2]),I] ;DZ/Dx
 Zy[INDGEN(s[1]),INDGEN(s[2]),I]   = SHIFT(Z[INDGEN(s[1]),INDGEN(s[2]),I],[0,D])-Z[INDGEN(s[1]),INDGEN(s[2]),I] ;DZ/Dy
 Zout[INDGEN(s[1]),INDGEN(s[2]),I] = SQRT(Zx[INDGEN(s[1]),INDGEN(s[2]),I]*Zx[INDGEN(s[1]),INDGEN(s[2]),I]+Zy[INDGEN(s[1]),INDGEN(s[2]),I]*Zy[INDGEN(s[1]),INDGEN(s[2]),I]) 
ENDFOR
RETURN,Zout
END
