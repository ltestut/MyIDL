PRO monthly_stat, st_input, stj, stm, stn, yy, N_val, moy, rms, trend, val_min, val_max, delta, $
                  nval=nval, nday=nday, monthly=monthly, verbose=verbose, demerliac=demerliac
; stj           => moy. journ. calculees pour au - *nval* val/jour
; stm           => moy. mens.  calculees pour au - *nday* jours/mois
; stn           => nbre de jour utilise pour le calcul de la moy. mens.
; yy            => tableau des annees de chacune des moyennes mensuelles
; N_val(13)     => de [0:11] nbre de moy. mens. utilise pour chaque mois         & [12] = TOTAL de tous les mois utiles de la serie
; moy(13)       => de [0:11] moy. des moy. mens. pour chacun des mois            & [12] = MOYENNE de l'ensemble des mois disponibles
; rms(13)       => de [0:11] ect des moy. mens. pour chacun des mois             & [12] = ECART-TYPE de l'ensemble des mois disponibles
; trend(13)     => de [0:11] tendance des moy mens. pour chacun des mois         & [12] = TENDANCE sur l'ensemble des mois disponibles
; val_min(13)   => de [0:11] valeur mens. min pour chacun des mois               & [12] = MIN mensuelle de toute la serie
; val_max(13)   => de [0:11] valeur mens. max pour chacun des mois               & [12] = MAX mensuelle de toute la serie
; delta(13)     => de [0:11] ecart max entre valeurs mens. pour chacun des mois  & [12] = ECART-MAX mensuelle de toute la serie

IF NOT KEYWORD_SET(nval) THEN nval=6  ;moy pour au moins nval valeurs par jour
IF NOT KEYWORD_SET(nday) THEN nday=4  ;moy pour au moins nday jours par mois
samp = sampling_julval(st_input)/3600.;ech. de la serie en heures

IF (samp GT 12.) THEN BEGIN ;pour un ech. > 12. on skip le calcul des moy. journ.
   stj  = st_input
   nday = 1
ENDIF ELSE BEGIN 
  ; methode de calcul des moy. journ.
  IF KEYWORD_SET(demerliac) THEN BEGIN
   stj  = detide_julval(st_input,METHOD='dem',/DAILY) ;calcul des moyennes journalieres avec demerliac
   nval = 71
  ENDIF ELSE BEGIN
   stj  = daily_mean(st_input,NVAL=nval)  ;calcul des moyennes journalieres sur 24h
  ENDELSE
ENDELSE
stm  = monthly_mean(stj,NMIN=nday)        ;calcul des moyennes mensuelles
stn  = monthly_mean(stj,NMIN=nday,/num)   ;calcul nbre de jour utilisees pour le calcul

Nm      = 12
N_val   = INTARR(Nm+1) ;nbre de valeur pour chaque mois & [12]=TOTAL pour l'ensemble mois
val_min = FLTARR(Nm+1) ;val_min pour chaque mois        & [12]=MIN pour l'ensemble mois
val_max = FLTARR(Nm+1) ;val_max pour chaque mois        & [12]=MAX pour l'ensemble mois
delta   = FLTARR(Nm+1) ;ecart max pour chaque mois      & [12]=ECART-MAX pour l'ensemble mois
moy     = FLTARR(Nm+1) ;moyenne des moyennes mensuelles & [12]=MOYENNE de l'ensemble des jours disponible
rms     = FLTARR(Nm+1)
trend   = FLTARR(Nm+1)

IF KEYWORD_SET(monthly) THEN BEGIN
  st = stm
ENDIF ELSE BEGIN
  st = stj
ENDELSE

IF KEYWORD_SET(verbose) THEN BEGIN
 meth='arth_24h'
 IF KEYWORD_SET(demerliac) THEN meth='demerliac'
 PRINT,"::::::::::::::::MONTHLY_STAT:::::::::::"
 PRINT,'Echantillonnage initial de la serie   : '+STRCOMPRESS(STRING(samp,FORMAT='(F8.3)'),/REMOVE_ALL)+' H'
 PRINT,'Calcul des moy. journ. pour au moins  : '+STRCOMPRESS(STRING(nval,FORMAT='(I2)'),/REMOVE_ALL)+' val/jour & method=',meth
 PRINT,'Calcul des moy. mens.  pour au moins  : '+STRCOMPRESS(STRING(nday,FORMAT='(I2)'),/REMOVE_ALL)+' jour/mois'
 PRINT,"------------------------------tableau des valeurs mensuelles---------------------------"
ENDIF

CALDAT,st.jul,mm,dd,yy ;on decoupe la serie en tableaux mois/jour/an
  
FOR i=0,11 DO BEGIN
   id         = WHERE(mm EQ (i+1),count)      ;recupere les indices des mois de 1 a 12
 IF (count GE 1) THEN BEGIN                    ;si on a au moins 1 valeur pour le mois i 
   id2        = WHERE(FINITE(st[id].val),cval)  ;indice des valeurs non-nulles du mois i
   N_val[i]   = cval                            ;nbre de valeur non-nulles pour le mois i
   val_min[i] = MIN(st[id].val,/NAN)            ;val min pour le mois i 
   val_max[i] = MAX(st[id].val,/NAN)            ;val max pour le mois i
   delta[i]   = val_max[i]-val_min[i]           ;ecart maximum pour le mois i
   moy[i]     = MEAN(st[id].val,/NAN)           ;valeur moyenne du mois i
   rms[i]     = STDDEV(st[id].val,/NAN)         ;ecart-type du mois i
   IF (cval GE 2) THEN BEGIN                     ;si on a au moins 2 valeurs pour le mois i
      r_coef   = LINFIT(st[id[id2]].jul,st[id[id2]].val)   ;y=a+bx (avec b en unit/jours)
      trend[i] = r_coef[1]*365.*10.                        ;calcul de la tendance sur les valeurs non-nulles en 10*unit/an
   ENDIF ELSE BEGIN
      trend[i] = !VALUES.F_NAN
   ENDELSE   
 ENDIF ELSE BEGIN
   N_val[i]   = 0                               ;nbre de valeur non-nulles pour le mois i
   val_min[i] = !VALUES.F_NAN 
   val_max[i] = !VALUES.F_NAN
   delta[i]   = !VALUES.F_NAN
   moy[i]     = !VALUES.F_NAN
   rms[i]     = !VALUES.F_NAN
   trend[i]   = !VALUES.F_NAN
 ENDELSE
 IF KEYWORD_SET(verbose) THEN BEGIN
     PRINT,'Mois=',STRCOMPRESS(STRING(JULDAY(1+i,1,1),FORMAT='(C(CMoA))'),/REMOVE_ALL),' | Nd=',STRCOMPRESS(STRING(N_val[i],FORMAT='(I5)'),/REMOVE_ALL),$
        " Moy=",STRCOMPRESS(STRING(moy[i],FORMAT='(F7.1)'),/REMOVE_ALL)," Ect=",STRCOMPRESS(STRING(rms[i],FORMAT='(F6.1)'),/REMOVE_ALL),$
        " | [min/max/delta]=",'[',STRCOMPRESS(STRING(val_min[i],FORMAT='(F6.1)'),/REMOVE_ALL),'/',STRCOMPRESS(STRING(val_max[i],FORMAT='(F6.1)'),/REMOVE_ALL),'/',$
        STRCOMPRESS(STRING(delta[i],FORMAT='(F6.1)'),/REMOVE_ALL),']',$
        ' | Trend=',STRCOMPRESS(STRING(trend[i],FORMAT='(F8.1)'),/REMOVE_ALL)
 ENDIF
ENDFOR
N_val[12]   = TOTAL(N_val[0:11],/NAN) ;Nbre de valeur pour l'ensemble des mois
val_min[12] = MIN(val_min[0:11],/NAN)
val_max[12] = MAX(val_max[0:11],/NAN)
delta[12]   = MAX(delta[0:11],/NAN)
moy[12]     = MEAN(st.val,/NAN)   ;moyenne de l'ensemble des donnees journalieres
rms[12]     = STDDEV(st.val,/NAN) ;ecart-type de l'ensemble des donnees journalieres
id_trend    = WHERE(FINITE(st.val),c_trend)  ;indice des valeurs non-nulles de l'ensemble de la serie
   IF (c_trend GE 2) THEN BEGIN                     ;si on a au moins 2 valeurs pour la serie
      r_coef   = LINFIT(st[id_trend].jul,st[id_trend].val)   ;y=a+bx (avec b en unit/jours)
      trend[12] = r_coef[1]*365.*10.                         ;calcul de la tendance sur les valeurs non-nulles en 10*unit/an
   ENDIF ELSE BEGIN
      trend[12] = !VALUES.F_NAN
   ENDELSE   

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'Tendance sur les '+STRCOMPRESS(STRING(c_trend,FORMAT='(I5)'),/REMOVE_ALL)+' val disp. = ',STRCOMPRESS(STRING(trend[12],FORMAT='(F8.2)'),/REMOVE_ALL)+' unit*10./year'
ENDIF

END