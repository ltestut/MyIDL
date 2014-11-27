FUNCTION tide_phase, cplx

; Renvoie la phase à partir de partie reelle et imaginaire du complexe

phase=deg(ATAN(IMAGINARY(cplx),REAL_PART(cplx)))  ; ARGUMENT
neg=WHERE( phase LT 0. , cnt_neg)
IF (cnt_neg GT 0 ) THEN phase[neg]=phase[neg]+360

return, phase

END