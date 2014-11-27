FUNCTION bot2slev, st_bot, st_baro, rho=rho
; fonction qui renvoie l'equivalent du niveau de la mer
; a partir d'une serie de .bot et de pression atm. 

IF NOT KEYWORD_SET(rho) THEN rho=1.024
deno = rho*9.81      ;denominateur

; on calcul la pression atm. moyenne sur la periode a calcule
dmin    = MIN(st_bot.jul,/NAN)
dmax    = MAX(st_bot.jul,/NAN)
sta     = julcut(st_baro,dmin=dmin-1,dmax=dmax+1)
pa_mean = MEAN(sta.val,/NAN)
st_baro = interpol_julval(sta,st_bot,/VERB) ;on interpole sur le pas de temps de la serie de pression de fond

; on calcul l'equivalent niv. de la mer
st_slev     = create_julval(N_ELEMENTS(st_bot.jul))
st_slev.jul = st_bot.jul
st_slev.val = 10.*(st_bot.val-st_baro.val)/deno    ;niv. de la mer en cm

RETURN, st_slev
END