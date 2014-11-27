FUNCTION slev2ibslev, st_slev, st_baro, rho=rho, coef=coef
; fonction qui renvoie l'equivalent du niveau de la mer avec correction du ib
; a partir d'une serie de niv. de la mer et de pression atm.
; par defaut le coef =1 ; cad H_ib=-C*dPa/(rho*g) 

IF NOT KEYWORD_SET(rho)  THEN rho  = 1.024
IF NOT KEYWORD_SET(coef) THEN coef = 1.

deno = rho*9.81      ;denominateur

synchro_julval, st_slev, st_baro, sps$b, spb$s
st_ib     = create_julval(N_ELEMENTS(sps$b.jul))
st_ib.jul = sps$b.jul
ib_cor    = 10.*coef*(spb$s.val-MEAN(spb$s.val,/NAN))/deno
st_ib.val = sps$b.val+ib_cor

RETURN, st_ib
END