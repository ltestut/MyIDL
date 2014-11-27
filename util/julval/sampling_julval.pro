FUNCTION sampling_julval,st,verb=verb, noround=noround
;calcul l'echantillonnage de la serie et renvoie un arrondi de la valeur moyenne en secondes par defaut
; ajout le 30/04/2008 du mot-cle noround utile pour les donnees a 30s (type GPS)

IF (N_PARAMS() EQ 0) THEN STOP, 'USAGE: renvoie la valeur d echantillonnage moyen de la serie en secondes'
;c CALCUL DES PERIODES MOYENNE ET INSTANTANEE D'ECHANTILLONNAGE DE LA SERIE
;c ------------------------------------------------------------------------
st1     = remove_doublon(st)
tab_diff= -TS_DIFF(st1.jul,1,/DOUBLE)
Nd      = N_ELEMENTS(tab_diff)
ech_tab = tab_diff[0:Nd-2]
;izero   = WHERE(ech_tab EQ 0.,count)
;IF (count GT 0) THEN BEGIN
;   print,"Nbre de doublon de valeurs de temps: ",count
;   ech_tab[izero]=!VALUES.F_NAN 
;ENDIF
echxi   = MIN(ech_tab,/NAN)
echxm   = TOTAL(tab_diff,/NAN)/FLOAT(Nd)

IF KEYWORD_SET(verb) THEN BEGIN
  print,'SAMPLING_JUVAL : MEAN          SAMPLING   =',echxm,' Jour',echxm*24.,' Heures',echxm*24.*60.,' Minutes',echxm*24.*60.*60.,' Secondes'
  print,'SAMPLING_JUVAL : INSTANTANEOUS SAMPLING   =',echxi,' Jour',echxi*24.,' Heures',echxi*24.*60.,' Minutes',echxi*24.*60.*60.,' Secondes'
ENDIF

IF KEYWORD_SET(noround) THEN RETURN,echxi*24.*60.*60.
RETURN,ROUND(echxi*24.*60.*60.)
END
