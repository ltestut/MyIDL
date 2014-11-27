FUNCTION remove_monthly_annual_mean_cycle, st, plot=plot, daily=daily, _EXTRA=_EXTRA
; calcul les valeurs moyennes pour chaque mois sur la serie complete
; et enleve ce cycle moyen a la serie initiale

IF KEYWORD_SET(daily) THEN BEGIN
   stm        = daily_mean(st,NVAL=4)          ;calcul des moyennes journaliere
ENDIF ELSE BEGIN
   stm        = monthly_mean(st,_EXTRA=_EXTRA) ;calcul des moyennes mensuelles pour toute la serie
ENDELSE
st_out     = create_rms_julval(N_ELEMENTS(stm.jul)) ;struc des sorties 
st_out.jul = stm.jul
 
CALDAT,stm.jul,mm,dd,yy
Nm      = 12         ;nombre de mois dans l'annee
ytab    = FLTARR(Nm) ;tableau des valeurs annuelles
N_val   = INTARR(Nm)
val_min = FLTARR(Nm)
val_max = FLTARR(Nm)
delta   = FLTARR(Nm)
moy     = FLTARR(Nm)
rms     = FLTARR(Nm)

tot_mean = MEAN(stm.val,/NAN)
FOR i=0,11 DO BEGIN
   id         = WHERE(mm EQ (i+1),count)        ; recupere tous les mois de 1 a 12 
   id2        = WHERE(FINITE(stm[id].val),cval) ; nbre de valeur non nulles de chaque mois
   val_min[i] = MIN(stm[id].val,/NAN)           ;val min de chaque mois 
   val_max[i] = MAX(stm[id].val,/NAN)           ;val max de chaque mois
   N_val[i]   = cval                            ;nbre de valeur valid pour chaque mois
   delta[i]   = val_max[i]-val_min[i]
   moy[i]     = MEAN(stm[id].val,/NAN)          ;valeur moyenne de chaque mois
   IF (cval GE 2) THEN BEGIN 
      rms[i]         = STDDEV(stm[id].val,/NAN)
      st_out[id].val = stm[id].val-(moy[i]-tot_mean)    ;on retire l'anomalie pour le mois en question 
   ENDIF ELSE BEGIN
      rms[i]         = !VALUES.F_NAN
      st_out[id].val = stm[id].val                      ;on laisse tel quel 
   ENDELSE
ENDFOR

IF KEYWORD_SET(plot) THEN BEGIN
   titre="RMS avant = "+STRCOMPRESS(STRING(STDDEV(stm.val,/NAN),FORMAT='(F6.2)'),/REMOVE_ALL)+$
         " et apres = "+STRCOMPRESS(STRING(STDDEV(st_out.val,/NAN),FORMAT='(F6.2)'),/REMOVE_ALL)
   plot_julval,stm,st_out,title=titre
ENDIF
RETURN,st_out
;;Derniere modif le 26/08/2009
END
