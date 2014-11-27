FUNCTION multiple, n, nearest=nearest
; function qui renvoie tous les multiples de l'entier n
res = FLTARR(n)
mul = INDGEN(n)+1
 ;on calcul les residus entre la partie entiere et decimale
FOR i=0,n-1 DO res[i]=n/FLOAT(mul[i])-n/mul[i]
inul = WHERE(res EQ 0.,cpt)

IF KEYWORD_SET(nearest) THEN BEGIN
  diff  = ABS(mul[inul]-nearest) 
  inear = WHERE(diff EQ MIN(diff),cpt)
  IF (cpt GT 1) THEN inear=inear[0]
  RETURN,mul[inul[inear]]
ENDIF ELSE BEGIN
 RETURN,mul[inul]
ENDELSE
END