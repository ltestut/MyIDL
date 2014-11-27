PRO daily_stat, st, st_cut, stj, mat_day_val , samp, nval=nval, year=year, method=method, _EXTRA=_EXTRA
; calcul des moyennes journalieres a partir de differentes methodes pour une annee donnee
IF NOT KEYWORD_SET(nval)     THEN nval     = 6 ;moy pour au moins nval valeurs par jour

samp   = sampling_julval(st)/3600.        ;echantillonnage de la serie en heures
st_cut = julcut(st,TMIN=STRCOMPRESS(year,/REMOVE_ALL),TMAX=STRCOMPRESS((year+1),/REMOVE_ALL),/VERB)

IF NOT KEYWORD_SET(method) THEN BEGIN
   stj  = daily_mean(st_cut,NVAL=nval)         ;calcul des moyennes journalieres
ENDIF ELSE BEGIN
   stj  = ddm(st_cut,METHOD=method,_EXTRA=_EXTRA)
ENDELSE

CALDAT,stj.jul,mm,dd,yy                                          ;on decoupe la serie en vecteurs mois/jour/an
mat_day_val   = MAKE_ARRAY(12,31,/FLOAT,VALUE=!VALUES.F_NAN)     ;matrice des valeurs journalieres
mat_day_val[mm-1,dd-1] = stj.val 
END