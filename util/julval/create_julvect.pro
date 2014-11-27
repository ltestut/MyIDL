FUNCTION  create_julvect, N, nan=nan

IF (N LT 1) THEN STOP, '!! ERROR in CREATE_JULVECT : N must be greater than 0'

tmp = {jul:0.0D, u:0.0, v:0.0, val:0.0, cap:0.0}


IF KEYWORD_SET(nan) THEN BEGIN
   tmp = {jul:0.0D, u:!VALUES.F_NAN ,v:!VALUES.F_NAN, val:!VALUES.F_NAN, cap:!VALUES.F_NAN} 
ENDIF 

st  = replicate(tmp,N)

RETURN, st
END