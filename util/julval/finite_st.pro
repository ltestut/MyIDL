FUNCTION finite_st, st
; create a julval structure whitout NaN data
id = WHERE(FINITE(st.val),count)
nt = N_TAGS(st)
tn = TAG_NAMES(st)

IF (count GE 1) THEN BEGIN
  IF (nt EQ 2) THEN BEGIN
     stf=create_julval(count)
     stf.jul=st[id].jul
     stf.val=st[id].val
  ENDIF
  IF (nt GT 2) THEN BEGIN
     IF (tn[2] EQ 'RMS') THEN BEGIN
     stf=create_rms_julval(count)
     stf.jul=st[id].jul
     stf.val=st[id].val
     stf.rms=st[id].rms
     ENDIF ELSE BEGIN
     stf=create_julval(count)
     stf.jul=st[id].jul
     stf.val=st[id].val
     ENDELSE
  ENDIF  
ENDIF ELSE BEGIN
 stf=st
ENDELSE
RETURN, stf
END
