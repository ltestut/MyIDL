FUNCTION trimming_julval, st_in, N=N, replace=replace
; NaN of min and max values

IF NOT KEYWORD_SET(N) THEN N=1 
st = replicate_julval(st_in)

FOR I=0,N DO BEGIN
   val_min = MIN(st.val,/NAN)
   val_max = MAX(st.val,/NAN)
   imin    = WHERE(st.val EQ val_min, cpt1)
   imax    = WHERE(st.val EQ val_max, cpt2)
   IF (cpt1+cpt2 LT 2) THEN print,"Problem with min or max!"
   st[imin].val=!VALUES.F_NAN
   st[imax].val=!VALUES.F_NAN
ENDFOR

IF KEYWORD_SET(replace) THEN BEGIN
  st_in=replicate_julval(st)
  RETURN, st_in
ENDIF ELSE BEGIN
  RETURN,st
ENDELSE

END