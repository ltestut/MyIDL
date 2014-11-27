FUNCTION range_flag_julval, st_in, range=range, inside=inside, replace=replace
; NaN outside (by default) or inside a given range 

st      = replicate_julval(st_in)
val_min = MIN(st.val,/NAN)
val_max = MAX(st.val,/NAN)
IF NOT KEYWORD_SET(range) THEN range=[val_min,val_max] 


inan   = WHERE((st.val LT range[0]) OR (st.val GT range[1]), COMPLEMENT=in_nan, cpt)
print,"range_flag_julval, NaN values = ",range,cpt
IF KEYWORD_SET(inside) THEN inan=in_nan
IF (cpt GT 0) THEN st[inan].val= !VALUES.F_NAN
   
IF KEYWORD_SET(replace) THEN BEGIN
  st_in=replicate_julval(st)
  RETURN, st_in
ENDIF ELSE BEGIN
  RETURN,st
ENDELSE

END