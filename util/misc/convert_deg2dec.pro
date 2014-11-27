FUNCTION convert_deg2dec, deg
if (deg GE 0) THEN BEGIN
   degres  = FLOOR(deg) ; si sup 0
ENDIF ELSE BEGIN
   degres = CEIL(deg) ; si inf 0
ENDELSE

RETURN, degres
END 