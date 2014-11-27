FUNCTION chrono_type,chrono
;return a string with the chrono type
nkey = chrono.count()
IF (nkey GE 1) THEN BEGIN
  ctype = (chrono[(chrono.keys())[0]])[0] ;return the type of the first key
ENDIF ELSE BEGIN
  STOP,'chrono_type  : chrono is empty'
ENDELSE
RETURN,ctype
END