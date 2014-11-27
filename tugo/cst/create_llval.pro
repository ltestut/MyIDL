; fonction qui creer une structure de type lon,lat,valeur (llval)
; ---------------------------------------------------------------
FUNCTION  create_llval, N, nan=nan
IF (N LT 1) THEN STOP, '!! ERROR in CREATE_LLZ : N must be greater than 0'
tmp = {lon:0.0D, lat:0.0D, val:0.0}
IF KEYWORD_SET(nan) THEN tmp = {lon:0.0D, lat:0.0D, val:!VALUES.F_NAN} ;si /NAN initialisation de val a NaN 
st  = replicate(tmp,N)
RETURN, st 
END