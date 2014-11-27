PRO glin, X, A, F, pder 
;F(x) = a *x + b  
;F(x) = A[0]*x+A[1]
;dF/da = x 
;dF/db = 1.
;;a * x * EXP(b*x) 
;df/dc = 1.0 
 
F = A[0] * X + A[1] 
 
;If the procedure is called with four parameters, calculate the 
;partial derivatives. 
  IF N_PARAMS() GE 4 THEN $ 
    pder = [[X], [replicate(1.0, N_ELEMENTS(X))]] 
END 

