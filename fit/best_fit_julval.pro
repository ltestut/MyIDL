FUNCTION best_fit_julval, st, fct=fct
; calcul le best fit sur julval
w   = MAKE_ARRAY(N_ELEMENTS(st.jul),VALUE=1.)

IF NOT KEYWORD_SET(fct) THEN fct='log'
IF (fct EQ 'log') THEN BEGIN
  al  = [1.,0.01,1.,1.]
  PRINT,"Fit avec un log"
ENDIF
IF (fct EQ 'gsaison') THEN BEGIN
  al  = [1.,1.]
  PRINT,"Fit avec un signal saisonnier"
ENDIF
IF (fct EQ 'gexp') THEN BEGIN
  al  = [0.,1.,1.]
  PRINT,"Fit avec une exp"
ENDIF
IF (fct EQ 'glin') THEN BEGIN
  al  = [1.,1.]
  PRINT,"Fit avec une droite"
ENDIF
IF (fct EQ 'gpoly2') THEN BEGIN
  al  = [0.1,1.,1.]
  PRINT,"Fit avec un poly 2"
ENDIF


sfa = CURVEFIT(st.jul,st.val,w,al,FUNCTION_NAME=fct)
print,al
print,size(st,/DIM)
stf    = create_julval(N_ELEMENTS(st))
stf.jul= st.jul
stf.val= sfa ;fit 

RETURN, stf
END