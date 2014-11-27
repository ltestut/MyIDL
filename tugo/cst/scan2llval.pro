PRO scan2llval, filename=filename, vec=vec


IF KEYWORD_SET(vec) THEN BEGIN
st  =  read_scan(filename,/vec)
ENDIF ELSE BEGIN
st  =  read_scan(filename)
ENDELSE

out =  write_scan2llval(st, filename=filename)

END
