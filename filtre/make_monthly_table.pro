FUNCTION make_monthly_table, st, rep_out=rep_out, plot=plot, nday=nday, nval=nval, _EXTRA=_EXTRA
IF NOT KEYWORD_SET(nval)     THEN nval     = 6 ;moy pour au moins nval valeurs par jour
IF NOT KEYWORD_SET(nday)     THEN nday     = 1 ;moy pour au moins nday jours par mois
IF NOT KEYWORD_SET(rep_out)  THEN rep_out = !desk ;repertoire de sortie
; liste des fichiers et figures de sortie
table1     = rep_out+'monthly_table.txt'
table2     = rep_out+'monthly_table.xls'
fig_histo  = rep_out+'histo_daily'
fig_ts     = rep_out+'ts_all'
fig_tsa    = rep_out+'ts_annual'

samp = sampling_julval(st)/3600.        ;echantillonnage de la serie en heures
; on calcul les stats mensuelles a partir des donnees journalieres
; ----------------------------------------------------------------
monthly_stat, st,       stj, stm, stn, yd, Ndpm,  moy_d, rms_d, trend_d, val_min_d, val_max_d, delta_d, nval=nval, nday=nday, _EXTRA=_EXTRA
; stj           => moyennes journalieres calculees pour au moins *nval* valeurs par jour
; stm           => moyennes mensuelles   calculees pour au moins *nday* jours par mois
; stn           => nbre de jour utilise pour le calcul de la moyenne mensuelle
; yd            => tableau des annees de chacune des moyennes journalieres
; Ndpm(13)      => de [0:11] nbre de jours total utilise pour chaque mois        & [12] = TOTAL de tous les jours utiles de la serie
; moy_d(13)     => de [0:11] moyenne des moyennes journ. pour chacun des mois    & [12] = MOYENNE de l'ensemble des jours disponibles
; rms_d(13)     => de [0:11] ect des moyennes journ. pour chacun des mois        & [12] = ECART-TYPE de l'ensemble des jours disponibles
; trend_d(13)   => de [0:11] tendance des moy journ. pour chacun des mois        & [12] = TENDANCE sur l'ensemble des jours disponibles
; val_min_d(13) => de [0:11] valeur journaliere mininum pour chacun des mois     & [12] = MIN journalier de toute la serie
; val_max_d(13) => de [0:11] valeur journaliere maximum pour chacun des mois     & [12] = MAX journalier de toute la serie
; delta_d(13)   => de [0:11] ecart max entre valeurs journ. pour chacun des mois & [12] = ECART-MAX journalier de toute la serie
id_d       = WHERE(FINITE(moy_d[0:11])) ;index de moyennes mens. (<-journ.) non nulles

; on calcul les stats mensuelles a partir des donnees mensuelles
; --------------------------------------------------------------
monthly_stat, st, stj, stm, stn, ym, nmth,  moy_m, rms_m, trend_m, val_min_m, val_max_m, delta_m, nval=nval, nday=nday, /MONTHLY, _EXTRA=_EXTRA
; stj           => moyennes journalieres calculees pour au moins *nval* valeurs par jour
; stm           => moyennes mensuelles   calculees pour au moins *nday* jours par mois
; stn           => nbre de jour utilise pour le calcul de la moyenne mensuelle
; ym            => tableau des annees de chacune des moyennes mensuelles
; nmth(13)      => de [0:11] nbre de moy. mens. utilise pour chaque mois         & [12] = TOTAL de tous les mois utiles de la serie
; moy_m(13)     => de [0:11] moyenne des moyennes mens. pour chacun des mois     & [12] = MOYENNE de l'ensemble des mois disponibles
; rms_m(13)     => de [0:11] ect des moyennes mens. pour chacun des mois         & [12] = ECART-TYPE de l'ensemble des mois disponibles
; trend_m(13)   => de [0:11] tendance des moy mens. pour chacun des mois         & [12] = TENDANCE sur l'ensemble des mois disponibles
; val_min_m(13) => de [0:11] valeur mensuelle mininum pour chacun des mois       & [12] = MIN mensuelle de toute la serie
; val_max_m(13) => de [0:11] valeur mensuelle maximum pour chacun des mois       & [12] = MAX mensuelle de toute la serie
; delta_m(13)   => de [0:11] ecart max entre valeurs mens. pour chacun des mois  & [12] = ECART-MAX mensuelle de toute la serie
id_m       = WHERE(FINITE(moy_m[0:11])) ;index de moyennes mens. (<-mens.) non nulles

; on calcul les stats annuelles a partir des donnees brutes
; ---------------------------------------------------------
annual_stat, st, sta, ym, ny, tab_val, tab_nbr , ndpy, nval=nval, nday=nday, /VERBOSE, _EXTRA=_EXTRA
; sta            => moyennes annuelles calculees a partir des donnees journ.
;                  .jul  -> date moyenne au 15 juin de l'annee
;                  .val  -> valeur de la moy. annuelle
;                  .rms  -> ecart-type de la moy. annuelle (sur les donnees journ.)                
; ym             => tableau des annees de chacune des moyennes mensuelles
; Ny             => nbr d'annees utile
; tab_val(12,Ny) => tableau [0<->12,Ny] des valeurs des moyennes mensuelles par annee 
; tab_nbr(12,Ny) => tableau [0<->12,Ny] des nbr de jour utilise pour le calcul des moyennes mensuelles par annee 
; Ndpy(Ny)       => nbr de moy. journ. utilise pour chaque annee 
r_coef      = LINFIT(sta.jul,sta.val)   ;y=a+bx (avec b en unit/jours)
trend_a     = r_coef[1]*365.*10.        ;calcul de la tendance sur les valeurs non-nulles en 10*unit/an


write_monthly_table, st, stj, stm, stn, sta, samp, nval, nday, ndpm, nmth, ny, ym, id_d, id_m, trend_a, $
                     moy_d, rms_d, trend_d, val_min_d, val_max_d, delta_d, $
                     moy_m, rms_m, trend_m, val_min_m, val_max_m, delta_m, $
                     tab_val, tab_nbr , ndpy, $
                     FILENAME=table1, _EXTRA=_EXTRA
                     
write_monthly_table, st, stj, stm, stn, sta, samp, nval, nday, ndpm, nmth, ny, ym, id_d, id_m, trend_a, $
                     moy_d, rms_d, trend_d, val_min_d, val_max_d, delta_d, $
                     moy_m, rms_m, trend_m, val_min_m, val_max_m, delta_m, $
                     tab_val, tab_nbr , ndpy, $
                     FILENAME=table2, /XLS ;ecriture de la table au format lisible par EXCEL (pour inclusion dans WORD)



plot_histo,stj.val, OUTPUT=fig_histo, /PNG, TITLE='HISTOGRAM OF DAILY MEAN'
plot_julval,stj,stm,sta,OUTPUT=fig_ts, /PNG ,/NO_FIT, TITLE='RAW, MONTLHY AND ANNUAL TIME SERIE', _EXTRA=_EXTRA
; calcul de l'erreur d'echantillonnage
sta.rms = sta.rms/SQRT(ndpy)
;ploterr_julval,sta, OUTPUT=fig_tsa, /PNG, /LINFIT, _EXTRA=_EXTRA

IF KEYWORD_SET(plot) THEN BEGIN
   WSET,0
   plot_julval,sta,WINDOW=0,title='Annual Mean'
   st_plot      = create_rms_julval(12)
   st_plot2     = create_julval(12)
   
   st_plot.jul  = stm[0:11].jul-14.D ; on se cale le premier jour du mois
   st_plot2.jul = st_plot.jul
   st_plot.val  = moy_m[0:11]
   st_plot.rms  = rms_m[0:11]
   st_plot2.val = trend_m[0:11]
   yrange = [MIN(moy_m)-MAX(rms_m),MAX(moy_m)+MAX(rms_m)]
   ploterr_julval,/data,st_plot,st_plot2,/raxis,yrange=yrange,ta='only_month',xstyle=2,WINDOW=1,$
                  title='Annual Mean Cycle'
ENDIF

RETURN, stm
END