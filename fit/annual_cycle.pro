FUNCTION annual_cycle,X,M
;; F(x)= Af*cos(2pif.X)+Bf*sin(2pif.X)+Cf
;; A[0]=Af
;; A[1]=Bf
dpi   = 2*!PI
freq  = 1./365. 
RETURN,[COS(dpi*freq*X),SIN(dpi*freq*X),1.]
END