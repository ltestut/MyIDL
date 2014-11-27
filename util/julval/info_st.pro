FUNCTION info_st, st, tmin=tmin, tmax=tmax, measure_error=measure_error, scale=scale, fit=fit, verb=verb, _EXTRA=_EXTRA

IF (N_PARAMS() EQ 0) THEN STOP, "UTILISATION:  info=info_st(st,tmin=tmin,tmax=tmax,measure_error=measure_error,/fit,/verb)"
ERROR='NO DATA IN THIS PERIOD'

IF NOT KEYWORD_SET(measure_error) THEN measure_error=0.1
IF NOT KEYWORD_SET(scale)         THEN scale=1.0

dmin=0.0D
dmax=0.0D

; Calcul de differentes informations sur des periodes temporelles donnees
; -----------------------------------------------------------------------
kmin = N_ELEMENTS(tmin) & kmax = N_ELEMENTS(tmax) ;test de la presence du mot-cle tmin & tmax
dmin = MIN(st.jul,/NAN,MAX=dmax)
smin = 0 & smax= 0 ;initialisation des longeurs de chaine de caractere
IF (kmin NE 0) THEN BEGIN
   smin=STRLEN(tmin)
   READS,tmin,dmin,FORMAT=get_format(smin)
ENDIF
IF (kmax NE 0) THEN BEGIN
   smax=STRLEN(tmax)
   READS,tmax,dmax,FORMAT=get_format(smax)
ENDIF
IF (dmax LT dmin) THEN BEGIN
 STOP,'ATTENTION: tmin > tmax'
ENDIF
stot=smax>smin ;on choisit le format le plus precis

i         = WHERE((st.jul GE dmin) AND (st.jul LE dmax) AND FINITE(st.val),count,/L64)
s_start   = st[MIN(i)].jul ;serie start
s_end     = st[MAX(i)].jul ;serie end
duration  = s_end-s_start
IF KEYWORD_SET(verb) THEN BEGIN
   print,"Interval duration                    : ",duration,'  Days / ',duration*24.,' Hours'
   print,"Number of values inside the interval : ",count
ENDIF
tab_error = MAKE_ARRAY(count,/FLOAT,VALUE=measure_error,/L64) ; Prescription de l'erreur de mesure par defaut
IF (N_TAGS(st) EQ 3) THEN tab_error=st[i].rms
Nd        = FLOOR((dmax-dmin)*24)
Nnan      = Nd-count
ech       = sampling_julval(remove_doublon(julcut(st,dmin=s_start,dmax=s_end))) ;echantillonnage sur le periode visualisee
   
IF (count GE 2) THEN BEGIN
;   r_coef    = LINFIT(st[i].jul,st[i].val,SIGMA=err,MEASURE_ERRORS=tab_error,YFIT=lin_fit)
   r_coef    = LINFIT(st[i].jul,st[i].val*scale,SIGMA=err,YFIT=lin_fit)
   
   rms       = STDDEV(st[i].val*scale,/NAN)
   med       = MEDIAN(st[i].val*scale)
   ENDIF ELSE BEGIN
   r_coef = [0.,0.]
   err    = [0.,0.]
   rms    = 0.
   med    = 0. 
ENDELSE

info=CREATE_INFO(count)
str1 = STRING('-[Ndata=',STRCOMPRESS(STRING(count),/REMOVE_ALL),']',$
;              '-[Nnan=' ,STRCOMPRESS(STRING(Nnan),/REMOVE_ALL),']',$
              '-[Min='  ,STRCOMPRESS(STRING(MIN(st[i].val*scale,/NAN),FORMAT='(F9.3)'),/REMOVE_ALL),']',$
              '-[Max='  ,STRCOMPRESS(STRING(MAX(st[i].val*scale,/NAN),FORMAT='(F9.3)'),/REMOVE_ALL),']')


frmt = '(F8.3)'
;str1 = STRING('-[Min='  ,STRCOMPRESS(STRING(MIN(st[i].val,/NAN),FORMAT='(F9.3)'),/REMOVE_ALL),']',$
;              '-[Max='  ,STRCOMPRESS(STRING(MAX(st[i].val,/NAN),FORMAT='(F9.3)'),/REMOVE_ALL),']')

str2 = STRING('-[Moy='  ,STRCOMPRESS(STRING(MEAN(st[i].val*scale,/NAN),FORMAT='(F9.3)'),/REMOVE_ALL),']',$
              '-[Std='  ,STRCOMPRESS(STRING(rms,FORMAT='(F9.3)'),/REMOVE_ALL),']',$
              '-[Med='  ,STRCOMPRESS(STRING(med,FORMAT='(F9.3)'),/REMOVE_ALL),']',$
              '-[Trd='  ,STRCOMPRESS(STRING(r_coef[1]*365.,FORMAT='(F9.3)'),/REMOVE_ALL),' --/yr +/-  ')+STRING(err[1]*365.,FORMAT='(F9.3)')+']'
str3 = STRING('- From ' ,print_date(s_start,/single),' --> ',print_date(s_end,/single),' ( ')+$
                         STRCOMPRESS(STRING(ROUND(duration)),/REMOVE_ALL)+' Days or '+$
                         STRCOMPRESS(STRING(duration*24.,FORMAT='(F10.2)'),/REMOVE_ALL)+' Hours)'
str4 = STRING('- Sampling rate =' ,STRCOMPRESS(STRING(ech/3600.,FORMAT=frmt),/REMOVE_ALL),'h / ',$
                                 STRCOMPRESS(STRING(ech/60.,FORMAT=frmt),/REMOVE_ALL),'mn / ',$
                                 STRCOMPRESS(STRING(ech,FORMAT=frmt),/REMOVE_ALL),'s')

;remove the str1
info.str=[str1,str2,str3,str4]
info.ind=i
 IF (KEYWORD_SET(fit) AND (count GT 2)) THEN RETURN,lin_fit 
RETURN,info

END
