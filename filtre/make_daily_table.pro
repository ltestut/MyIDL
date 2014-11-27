FUNCTION make_daily_table, st, rep_out=rep_out, nval=nval, year=year, _EXTRA=_EXTRA
IF NOT KEYWORD_SET(year)    THEN year     = 1950 
IF NOT KEYWORD_SET(nval)    THEN nval     = 6 ;moy pour au moins nval valeurs par jour
IF NOT KEYWORD_SET(rep_out) THEN rep_out = 'C:/Documents and Settings/TESTUT/Bureau/' ;repertoire de sortie

; liste des fichiers et figures de sortie
table1     = rep_out+'daily_table_'+STRCOMPRESS(year,/REMOVE_ALL)+'.txt'

; on calcul les stats journalieres a partir des donnees brutes
; ------------------------------------------------------------
daily_stat, st,  stc, stj, tab_val, samp, nval=nval, year=year, _EXTRA=_EXTRA
; st            => c'est la serie brutes en input
; stc           => serie coupe pour l'annee *year* specifiee
; stj           => moyennes journalieres calculees pour au moins *nval*/jours ou selon une autre methode
; samp          => echantillonnage de la serie input

write_daily_table, st, stc, stj, tab_val, samp, nval, $
                     FILENAME=table1, _EXTRA=_EXTRA
                     

RETURN, stc
END