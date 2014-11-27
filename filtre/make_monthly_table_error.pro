FUNCTION make_monthly_table_error, st, file_out=file_out, sigma=sigma, level=level, gauss=gauss,  _EXTRA=_EXTRA
IF NOT KEYWORD_SET(level) THEN level = 0.95
samp = sampling_julval(st)                       ;calcul de l'echantillonnage de la serie
IF (samp LT 86400) THEN st=daily_mean(st,NVAL=4) ;calcul de la moy journaliere
sig_tot = STDDEV(st.val)                             ;ecart-type de la serie avant calcul de la moyenne
stm     = monthly_mean(st,nmin=1,_EXTRA=_EXTRA)      ;calcul des moyennes mensuelles des qu'il y a une valeur
stn     = monthly_mean(st,nmin=1,/num,_EXTRA=_EXTRA) ;calcul nbre de val utilisees pour le calcul

IF NOT KEYWORD_SET(sigma) THEN sigma=sig_tot
IF NOT KEYWORD_SET(file_out) THEN file_out='C:\Documents and Settings\TESTUT\Bureau\table_error.txt'

PRINT,"Calcul de la table des moyennes et des erreurs"
PRINT,"Pour un ecart-type theorique de : ",STRCOMPRESS(sigma,/REMOVE_ALL)
PRINT,"Et un niveau de confiance de    : ",STRCOMPRESS(level*100.,/REMOVE_ALL),"%"


CALDAT,stm.jul,mm,dd,yy
Nm      = 12         ;nombre de mois dans l'annee
ytab    = FLTARR(Nm) ;tableau des valeurs annuelles
N_val   = INTARR(Nm)
val_min = FLTARR(Nm)
val_max = FLTARR(Nm)
delta   = FLTARR(Nm)
moy     = FLTARR(Nm)
rms     = FLTARR(Nm)
trend   = FLTARR(Nm)
header1 = '            -ooO TABLE DES MOYENNES MENSUELLES DES DONNEES JOURNALIERES Ooo-                   '
header2 = '                           intervalle de confiance de '+STRCOMPRESS(STRING(level*100,FORMAT='(I4)'),/REMOVE_ALL)+'%'
header3 = '                           ecart-type theorique de '+STRCOMPRESS(STRING(sigma,FORMAT='(F6.1)'),/REMOVE_ALL)
lineh   = '---- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ | ------ ------'
lmonthh = 'year Jan    Feb    Mar    Apr    May    Jun    Jul    Aug    Sep    Oct    Nov    Dec    |  Mean    Rms '
line    = '---- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------'
line2   = '==== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======'
lmonth  = 'year Jan    Feb    Mar    Apr    May    Jun    Jul    Aug    Sep    Oct    Nov    Dec'


   ; ecriture de l'entete du fichier  
OPENW,  UNIT, file_out  , /GET_LUN
PRINTF,UNIT,header1
PRINTF,UNIT,header2
PRINTF,UNIT,header3
PRINTF,UNIT,lineh
PRINTF,UNIT,lmonthh
PRINTF,UNIT,lineh

FOR i=0,11 DO BEGIN
   id         = WHERE(mm EQ (i+1),count)        ; recupere tous les mois de 1 a 12 
   id2        = WHERE(FINITE(stm[id].val),cval) ; nbre de valeur non nulles de chaque mois
   val_min[i] = MIN(stm[id].val,/NAN) ;val min de chaque mois 
   val_max[i] = MAX(stm[id].val,/NAN) ;val max de chaque mois
   N_val[i]   = cval 
   delta[i]   = val_max[i]-val_min[i]
   moy[i]     = MEAN(stm[id].val,/NAN)
   IF (cval GE 2) THEN BEGIN 
      rms[i]     = STDDEV(stm[id].val,/NAN)
   ENDIF ELSE BEGIN
      rms[i]     = !VALUES.F_NAN
   ENDELSE
   IF (cval GT 2) THEN BEGIN
      r_coef   = LINFIT(stm[id[id2]].jul,stm[id[id2]].val) ;y=a+bx (avec b en unit/jours)
      trend[i] = r_coef[1]*365.*10.                       ;calcul de la tendance sur les valeurs non-nulles en 10*unit/an
   ENDIF ELSE BEGIN
      trend[i] = !VALUES.F_NAN
   ENDELSE
ENDFOR

moy_all      = MEAN(stm.val,/NAN) 
rms_all      = STDDEV(stm.val,/NAN)
stm2         = finite_st(stm)
r_coef_all   = LINFIT(stm2.jul,stm2.val)

FOR j=0,count-1 DO BEGIN ;boucle sur le nombre d'annee
   coef         = MAKE_ARRAY(12,VALUE=!VALUES.F_NAN)  ;tab des probabilites GAUSS ou STUDENT (init)
   lev_err      = MAKE_ARRAY(12,VALUE=!VALUES.F_NAN)  ;tab des interv. d'erreur pour un niv. de signification donnee (init)
   ytab=[stm[0+j*12].val,stm[1+j*12].val,stm[2+j*12].val,stm[3+j*12].val,stm[4+j*12].val,$
            stm[5+j*12].val,stm[6+j*12].val,stm[7+j*12].val,stm[8+j*12].val,stm[9+j*12].val,$
            stm[10+j*12].val,stm[11+j*12].val]                                                 ;tab des moy mensuelles
   ytab2=[stn[0+j*12].val,stn[1+j*12].val,stn[2+j*12].val,stn[3+j*12].val,stn[4+j*12].val,$
            stn[5+j*12].val,stn[6+j*12].val,stn[7+j*12].val,stn[8+j*12].val,stn[9+j*12].val,$
            stn[10+j*12].val,stn[11+j*12].val]                                                 ;tab des nbre de valeurs /mois
   cpt    = TOTAL(FINITE(ytab))
   ymean  = MEAN(ytab,/NAN)       ;moyenne pour l'annee
   ytot   = TOTAL(ytab2,/NAN)     ;nbre de valeur total pour l'annee
   yrms   = !VALUES.F_NAN
   IF KEYWORD_SET(gauss) THEN BEGIN                                                            ;calcul des coeff GAUSS ou STUDENT
   coef = MAKE_ARRAY(12,VALUE=GAUSS_CVF(1-level))
   ENDIF ELSE BEGIN
   id_cvf =  WHERE(ytab2 GE 2,cpt_cvf) ;partout ou il y a au moins 2 valeurs par mois
      IF (cpt_cvf GE 1) THEN BEGIN
         FOR k=0,N_ELEMENTS(id_cvf)-1 DO BEGIN
         coef[id_cvf[k]]    = T_CVF(1-level,ytab2[id_cvf[k]]-1)              ;coef pour le mois
         lev_err[id_cvf[k]] = coef[id_cvf[k]]*SIG_TOT/SQRT(ytab2[id_cvf[k]]) ;int de confiance pour le mois
         ENDFOR
         coef_tot    = T_CVF(1-level,ytot)                                   ;coef pour l'annee
         lev_err_tot = coef_tot*sig_tot/SQRT(ytot)                           ;int de confiance pour le mois
      ENDIF
   ENDELSE
   IF (cpt NE 1) THEN yrms=STDDEV(ytab,/NAN)
   PRINTF,UNIT,FORMAT='(I4,X,12(F6.1,X),A2,2(F6.1,X))',yy[0+j*12],stm[0+j*12].val,stm[1+j*12].val,stm[2+j*12].val,stm[3+j*12].val,stm[4+j*12].val,$
                                    stm[5+j*12].val,stm[6+j*12].val,stm[7+j*12].val,stm[8+j*12].val,stm[9+j*12].val,$
                                    stm[10+j*12].val,stm[11+j*12].val,'| ',ymean,yrms

   PRINTF,UNIT,FORMAT='(A4,X,12(I6,X),A2,I6)','NDAY',stn[0+j*12].val,stn[1+j*12].val,stn[2+j*12].val,stn[3+j*12].val,stn[4+j*12].val,$
                                    stn[5+j*12].val,stn[6+j*12].val,stn[7+j*12].val,stn[8+j*12].val,stn[9+j*12].val,$
                                    stn[10+j*12].val,stn[11+j*12].val,'| ',ytot
   PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X),A2,F6.1)','ERR ',lev_err[*],'| ',lev_err_tot
   PRINTF,UNIT,line
ENDFOR
PRINTF,UNIT,line
PRINTF,UNIT,FORMAT='(A4,X,12(I6,X))','Nval',N_val[0:11]
PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X))','Min ',val_min[0:11]
PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X))','Max ',val_max[0:11]
PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X))','Dmax',delta[0:11]
PRINTF,UNIT,line2
PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X),A2,F6.1)','Mean',moy[0:11],'| ',moy_all
PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X),A2,F6.1)','RMS ',rms[0:11],'| ',rms_all
PRINTF,UNIT,line2
PRINTF,UNIT,FORMAT='(A4,X,12(F6.1,X),F6.1,A17)','Tren',trend[0:11],r_coef_all[1]*365.*10.,' en 10. x Unit/yr'
PRINTF,UNIT,line2
PRINTF,UNIT,lmonth
FREE_LUN, UNIT
CLOSE, UNIT

PRINT,"Ecriture du fichier :",file_out

RETURN, stm
END