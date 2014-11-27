FUNCTION op_cmatrix, Z, s11=s11, amp=amp, pha=pha
;Z_out = 2*(Z[*,*,0:N/2]*CONJ(Z[*,*,0:N/2]))
s      = SIZE(Z)
Z_out  = FLTARR(s(1),s(2),(s(3)/2+1))

IF KEYWORD_SET(s11) THEN BEGIN 
   FOR I=0,s[3]/2 DO Z_out[INDGEN(s[1]),INDGEN(s[2]),I] = 2*Z[INDGEN(s[1]),INDGEN(s[2]),I]*CONJ(Z[INDGEN(s[1]),INDGEN(s[2]),I])
   RETURN,Z_out
ENDIF

IF KEYWORD_SET(amp) THEN BEGIN 
   FOR I=0,s[3]/2 DO Z_out[INDGEN(s[1]),INDGEN(s[2]),I] = 2*ABS(Z[INDGEN(s[1]),INDGEN(s[2]),I])
   RETURN,Z_out
ENDIF

IF KEYWORD_SET(pha) THEN BEGIN 
   FOR I=0,s[3]/2 DO Z_out[INDGEN(s[1]),INDGEN(s[2]),I] = ATAN(Z[INDGEN(s[1]),INDGEN(s[2]),I],/PHASE)*(360./(2*!PI)) ;phase en degres
   RETURN,Z_out
ENDIF

END
