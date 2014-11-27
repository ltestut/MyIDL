PRO log, X, A, F, pder
;; F(x)= A[0]*ALOG(A[1]*X+A[2])+A[3]

bx=ALOG(A[1]*X+A[2])
F=A[0]*bx+A[3]

IF N_PARAMS() GE 4 THEN pder=[[bx],[A[0]*X/(A[1]*X+A[2])],[A[0]/(A[1]*X+A[2])],[REPLICATE(1.0,N_ELEMENTS(X))]]

END
