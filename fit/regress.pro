PRO regress, st, str

IF (N_PARAMS() EQ 0) THEN BEGIN
   print, 'regress, stc, st'
   print, ''
   print, 'INPUT : stc --> structure de type ALTIERR'
   print, 'OUTPUT: sf  --> strcuture de type {jul,val}'
RETURN
ENDIF

tmp     = {jul:0.0D, val:0.0}
st      = REPLICATE(tmp,N_ELEMENTS(stc))
END