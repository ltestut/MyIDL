FUNCTION trend_annual_cycle,X,M
  ;; F(x)= Af*cos(2pif.X)+Bf*sin(2pif.X)+Cf*X+Df
  ;; A[0]=Af
  ;; A[1]=Bf
  ;; A[2]=Cf
  ;; A[3]=Df
  dpi   = 2*!PI
  freq  = 1./365.
  RETURN,[COS(dpi*freq*X),SIN(dpi*freq*X),X,1.]
END