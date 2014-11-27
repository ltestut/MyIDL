FUNCTION nbr_use_year, st, nday=nday, verbose=verbose
; renvoie le nbre d'annees utile de la serie
IF NOT KEYWORD_SET(nday) THEN nday=2
stm  = monthly_mean(st,NMIN=nday)  ;calcul des moyennes mensuelles
CALDAT,stm.jul,mm,dd,yy            ;on decoupe la serie en tableaux mois/jour/an
id   = WHERE(mm EQ 1,count)        ;recupere les indices des mois de janvier
IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,"nbr_use_year  : nbre d'annee utile =>",count
 PRINT,"nbr_use_year  : annees  =>",yy[id]
ENDIF
RETURN, count
END
