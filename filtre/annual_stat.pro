PRO annual_stat, st, sta_mean, yy, Nyear, mat_mth_val, mat_mth_nbr,  ndpy,  nval=nval, nday=nday, verbose=verbose, demerliac=demerliac
IF NOT KEYWORD_SET(nval)     THEN nval     = 6 ;moy pour au moins nval valeurs par jour
IF NOT KEYWORD_SET(nday)     THEN nday     = 1 ;moy pour au moins nday jours par mois

samp = sampling_julval(st)/3600.        ;echantillonnage de la serie en heures
IF KEYWORD_SET(demerliac) THEN BEGIN
   stj  = ddm(st)                       ;calcul des moyennes journalieres avec demerliac
   nval = 71
ENDIF ELSE BEGIN
   stj  = daily_mean(st,NVAL=nval)      ;calcul des moyennes journalieres sur 24h
ENDELSE
stm  = monthly_mean(stj,NMIN=nday)            ;calcul des moyennes mensuelles
stn  = monthly_mean(stj,NMIN=nday,/num)       ;calcul nbre de jour utilisees pour le calcul

CALDAT,stm.jul,mm,dd,yy                  ;on decoupe la serie en tableaux mois/jour/an
Nd_tot      = 0                          ;on initialise le compteur du nbre total de jour
Nyear       = nbr_use_year(st,NDAY=nday) ;on compte le nombre d'annee utile
mat_mth_val = FLTARR(12,Nyear)           ;matrice des valeurs mensuelles
mat_mth_nbr = INTARR(12,Nyear)           ;matrice des nbr de valeurs utilise par mois
sta_mean    = create_rms_julval(Nyear)   ;on creer une structure annuelle
ndpy        = INTARR(Nyear)              ;tab des nbr de val journ. par an
samp_err    = FLTARR(Nyear)              ;tab des erreurs d'echantillonnage nbr de val journ. par an

; boucle de calcul *ligne* des moyennes annuelles a partir des moyennes journalieres
; ===================================================================================
FOR j=0,Nyear-1 DO BEGIN ;boucle sur le nombre d'annee (ou par ligne)
   mat_mth_val[*,j]= [stm[0+j*12].val,stm[1+j*12].val,stm[2+j*12].val,stm[3+j*12].val,stm[4+j*12].val,$
                      stm[5+j*12].val,stm[6+j*12].val,stm[7+j*12].val,stm[8+j*12].val,stm[9+j*12].val,$
                      stm[10+j*12].val,stm[11+j*12].val]    ;tab des valeurs  de chaque mois
   mat_mth_nbr[*,j]= [stn[0+j*12].val,stn[1+j*12].val,stn[2+j*12].val,stn[3+j*12].val,stn[4+j*12].val,$
                      stn[5+j*12].val,stn[6+j*12].val,stn[7+j*12].val,stn[8+j*12].val,stn[9+j*12].val,$
                      stn[10+j*12].val,stn[11+j*12].val]    ;tab des nbre de valeurs /mois
   Ndpy[j]   = TOTAL(mat_mth_nbr[*,j],/NAN)  ;nbre de jours utile pour l'annee
   Nd_tot = Nd_tot+Ndpy[j]                   ;totalisateur des nbre de jours utiles
   sta    = julcut(stj,dmin=JULDAY(1,1,yy[0+j*12],0,0,0),dmax=JULDAY(1,1,yy[0+j*12]+1,0,0,0))
   ;ymean2 = MEAN(mat_mth_val[*,j],/NAN)   ;moyenne des moyennes mensuelles
   sta_mean[j].jul  = JULDAY(6,15,yy[0+j*12]) ;dates des moy annuelles
   sta_mean[j].val  = MEAN(sta.val,/NAN)      ;moyennes annuelles a partir de la moy. de tous les jours d'une meme annee   
   sta_mean[j].rms  = STDDEV(sta.val,/NAN)    ;ecart-type des moyennes journalieres par annee    
   ys_rms           = STDDEV(sta.val,/NAN)/SQRT(Ndpy[j])               ;erreur d'echantillonnage sig/racine(n) de l'annee       
   cpt    = TOTAL(FINITE(mat_mth_val[*,j]))
   yrms2  = !VALUES.F_NAN
   IF (cpt NE 1) THEN yrms2=STDDEV(mat_mth_val[*,j],/NAN) ;std des moyennes mensuelles
;   PRINT,"Annee =",STRCOMPRESS(yy[0+j*12],/REMOVE_ALL)," Ndpy",STRCOMPRESS(STRING(Ndpy[j],FORMAT='(I3.3)'),/REMOVE_ALL)," Moy(jour/mens)=",STRCOMPRESS(STRING(ymean,FORMAT='(F6.1)'),/REMOVE_ALL),'/',$
;          STRCOMPRESS(STRING(ymean2,FORMAT='(F6.1)'),/REMOVE_ALL)," RMS(jour/mens)=",STRCOMPRESS(STRING(yrms,FORMAT='(F6.1)'),/REMOVE_ALL),'/',STRCOMPRESS(STRING(yrms2,FORMAT='(F6.1)'),/REMOVE_ALL),$
;          " Samp_error=",STRCOMPRESS(ys_rms,/REMOVE_ALL)         
   ;PRINTF,UNIT,FORMAT='(I4,X,12(F6.1,X),A1,I3,A2,F5.1,X,F4.1,X,F4.1,A2,F5.1,X,F4.1,A1)',ym[0+j*12],stm[0+j*12].val,stm[1+j*12].val,stm[2+j*12].val,stm[3+j*12].val,stm[4+j*12].val,$
   ;                                 stm[5+j*12].val,stm[6+j*12].val,stm[7+j*12].val,stm[8+j*12].val,stm[9+j*12].val,$
   ;                                 stm[10+j*12].val,stm[11+j*12].val,'|',Nd_tot,'| ',ymean,yrms,ys_rms,'| ',ymean2,yrms2,'|'
   ;PRINT,FORMAT='(I4,X,12(F6.1,X),A1,I3,A2,F5.1,X,F4.1,X,F4.1,A2,F5.1,X,F4.1,A1)',yy[0+j*12],mat_mth_val[*,j],'|',Ndpy[j],'| ',sta_mean[j].val,STDDEV(sta_mean[j].val,/NAN),STDDEV(sta_mean[j].val,/NAN)/ndpy[j],'| ',ymean2,yrms2,'|'
   
   ;IF KEYWORD_SET(full) THEN BEGIN
   ;PRINTF,UNIT,FORMAT='(A4,X,12(I6,X))','NDAY',stn[0+j*12].val,stn[1+j*12].val,stn[2+j*12].val,stn[3+j*12].val,stn[4+j*12].val,$
   ;                                 stn[5+j*12].val,stn[6+j*12].val,stn[7+j*12].val,stn[8+j*12].val,stn[9+j*12].val,$
   ;                                 stn[10+j*12].val,stn[11+j*12].val
   ;PRINTF,UNIT,line
   ;ENDIF                  
ENDFOR













;Nm      = 12
;N_val   = INTARR(Nm+1) ;nbre de valeur pour chaque mois & [12]=TOTAL pour l'ensemble mois
;val_min = FLTARR(Nm+1) ;val_min pour chaque mois        & [12]=MIN pour l'ensemble mois
;val_max = FLTARR(Nm+1) ;val_max pour chaque mois        & [12]=MAX pour l'ensemble mois
;delta   = FLTARR(Nm+1) ;ecart max pour chaque mois      & [12]=ECART-MAX pour l'ensemble mois
;moy     = FLTARR(Nm+1) ;moyenne des moyennes mensuelles & [12]=MOYENNE de l'ensemble des jours disponible
;rms     = FLTARR(Nm+1)
;trend   = FLTARR(Nm+1)
;
;IF KEYWORD_SET(monthly) THEN BEGIN
;  st = stm
;ENDIF ELSE BEGIN
;  st = stj
;ENDELSE

  
;FOR i=0,11 DO BEGIN
;   id         = WHERE(mm EQ (i+1),count)      ;recupere les indices des mois de 1 a 12
; IF (count GE 1) THEN BEGIN                    ;si on a au moins 1 valeur pour le mois i 
;   id2        = WHERE(FINITE(st[id].val),cval)  ;indice des valeurs non-nulles du mois i
;   N_val[i]   = cval                            ;nbre de valeur non-nulles pour le mois i
;   val_min[i] = MIN(st[id].val,/NAN)            ;val min pour le mois i 
;   val_max[i] = MAX(st[id].val,/NAN)            ;val max pour le mois i
;   delta[i]   = val_max[i]-val_min[i]           ;ecart maximum pour le mois i
;   moy[i]     = MEAN(st[id].val,/NAN)           ;valeur moyenne du mois i
;   rms[i]     = STDDEV(st[id].val,/NAN)         ;ecart-type du mois i
;   IF (cval GE 2) THEN BEGIN                     ;si on a au moins 2 valeurs pour le mois i
;      r_coef   = LINFIT(st[id[id2]].jul,st[id[id2]].val)   ;y=a+bx (avec b en unit/jours)
;      trend[i] = r_coef[1]*365.*10.                        ;calcul de la tendance sur les valeurs non-nulles en 10*unit/an
;   ENDIF ELSE BEGIN
;      trend[i] = !VALUES.F_NAN
;   ENDELSE   
; ENDIF ELSE BEGIN
;   N_val[i]   = 0                               ;nbre de valeur non-nulles pour le mois i
;   val_min[i] = !VALUES.F_NAN 
;   val_max[i] = !VALUES.F_NAN
;   delta[i]   = !VALUES.F_NAN
;   moy[i]     = !VALUES.F_NAN
;   rms[i]     = !VALUES.F_NAN
;   trend[i]   = !VALUES.F_NAN
; ENDELSE
; IF KEYWORD_SET(verbose) THEN BEGIN
;     PRINT,'Mois=',STRCOMPRESS(STRING(JULDAY(1+i,1,1),FORMAT='(C(CMoA))'),/REMOVE_ALL),' | Nd=',STRCOMPRESS(STRING(N_val[i],FORMAT='(I5)'),/REMOVE_ALL),$
;           " Moy=",STRCOMPRESS(STRING(moy[i],FORMAT='(F7.1)'),/REMOVE_ALL)," Ect=",STRCOMPRESS(STRING(rms[i],FORMAT='(F6.1)'),/REMOVE_ALL),$
;           " | [min/max/delta]=",'[',STRCOMPRESS(STRING(val_min[i],FORMAT='(F6.1)'),/REMOVE_ALL),'/',STRCOMPRESS(STRING(val_max[i],FORMAT='(F6.1)'),/REMOVE_ALL),'/',$
;           STRCOMPRESS(STRING(delta[i],FORMAT='(F6.1)'),/REMOVE_ALL),']',$
;           ' | Trend=',STRCOMPRESS(STRING(trend[i],FORMAT='(F8.1)'),/REMOVE_ALL)
; ENDIF
;ENDFOR
;PRINT,'Echantillonnage initial de la serie      : '+STRCOMPRESS(STRING(samp,FORMAT='(F8.3)'),/REMOVE_ALL)+'H'
;N_val[12]   = TOTAL(N_val[0:11],/NAN) ;Nbre de valeur pour l'ensemble des mois
;val_min[12] = MIN(val_min[0:11],/NAN)
;val_max[12] = MAX(val_max[0:11],/NAN)
;delta[12]   = MAX(delta[0:11],/NAN)
;moy[12]     = MEAN(st.val,/NAN)   ;moyenne de l'ensemble des donnees journalieres
;rms[12]     = STDDEV(st.val,/NAN) ;ecart-type de l'ensemble des donnees journalieres
;id_trend    = WHERE(FINITE(st.val),c_trend)  ;indice des valeurs non-nulles de l'ensemble de la serie
;   IF (c_trend GE 2) THEN BEGIN                     ;si on a au moins 2 valeurs pour la serie
;      r_coef   = LINFIT(st[id_trend].jul,st[id_trend].val)   ;y=a+bx (avec b en unit/jours)
;      trend[12] = r_coef[1]*365.*10.                         ;calcul de la tendance sur les valeurs non-nulles en 10*unit/an
;   ENDIF ELSE BEGIN
;      trend[12] = !VALUES.F_NAN
;   ENDELSE   
;
;;Ndm[12]      = TOTAL(Ndm[0:11])
;;moy_all      = MEAN(stm.val,/NAN) 
;;rms_all      = STDDEV(stm.val,/NAN)
;;stm2         = finite_st(stm)
;;r_coef_all   = LINFIT(stm2.jul,stm2.val)
;;sta_mean     = create_rms_julval(count)
;; =====================================================================================
;



END