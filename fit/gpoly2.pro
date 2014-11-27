PRO gpoly2, X, A, F, pder 
;F(x) = a *x2 + b*x + c  
;F(x) = A[0]*x^2+A[1]*X+A[2]
;dF/da = X*X 
;dF/db = X
;dF/dc = 1.
;
 
F = A[0]*X*X + A[1]*X+A[2] 
 
;If the procedure is called with four parameters, calculate the 
;partial derivatives. 
  IF N_PARAMS() GE 4 THEN $ 
    pder = [[X*X],[X], [replicate(1.0, N_ELEMENTS(X))]] 
END 

