FUNCTION bot2ibslev, st_bot, st_baro, rho=rho
; fonction qui renvoie l'equivalent du niveau de la mer avec correction du ib
; a partir d'une serie de .bot et de pression atm. 

IF NOT KEYWORD_SET(rho) THEN rho=1.024
deno = rho*9.81      ;denominateur

; on calcul la pression atm. moyenne sur la periode a calcule
dmin    = MIN(st_bot.jul,/NAN)
dmax    = MAX(st_bot.jul,/NAN)
sta     = julcut(st_baro,dmin=dmi,dmax=dma)
pa_mean = MEAN(sta.val,/NAN)

; on calcul l'equivalent niv. de la mer
st_ib     = create_julval(N_ELEMENTS(st_bot.jul))
st_ib.jul = st_bot.jul
st_ib.val = 10.*(st_bot.val-pa_mean)/deno    ;niv. de la mer en cm

RETURN, st_ib
END