PRO plot_concordance_julval, st1, st2, tmin=tmin,tmax=tmax,cutinfo=cutinfo, daily=daily, verbose=verbose, name1=name1,name2=name2,zero=zero,_EXTRA=_EXTRA
; trace la droite de regresssion entre les serie 1 et 2
IF NOT KEYWORD_SET(name1) THEN name1='reference'
IF NOT KEYWORD_SET(name2) THEN name2='observatoire'
dmin = MIN(st1.jul) < MIN(st2.jul)
dmax = MAX(st1.jul) > MAX(st2.jul)
IF KEYWORD_SET(tmin) THEN BEGIN
   smin=STRLEN(tmin)
   READS,tmin,dmin,FORMAT=get_format(smin)
ENDIF
IF KEYWORD_SET(tmax) THEN BEGIN
   smax=STRLEN(tmax)
   READS,tmax,dmax,FORMAT=get_format(smax)
ENDIF
st1 =julcut(st1,DMIN=dmin,DMAX=dmax)
st2 =julcut(st2,DMIN=dmin,DMAX=dmax)
IF KEYWORD_SET(daily) THEN BEGIN
   print,"Concordance sur les moyennes journalieres"
   st1=daily_mean(st1)
   st2=daily_mean(st2)
ENDIF
st1 = finite_st(st1)
st2 = finite_st(st2)

synchro_julval, st1, st2, st1$2, st2$1, bs=60.

s_start = MIN(st1$2.jul)
s_end   = MAX(st1$2.jul)
yref     = st1$2.val
yref_moy = MEAN(yref)
y        = st2$1.val
y_moy    = MEAN(y)
IF KEYWORD_SET(zero) THEN BEGIN
   xrange = [0.,MAX(yref)]
   yrange = [0.,MAX(y)]
ENDIF ELSE BEGIN
   xrange = [MIN(yref),MAX(yref)]
   yrange = [MIN(y),MAX(y)]
ENDELSE


; calcul du doefficient de regression
; y = r_coef[0]+r_coef[1]*yref
r_coef  = LINFIT(yref,y,sigma=err,yfit=yfit)
origine = r_coef[0]
pente   = r_coef[1]
tname   =['N.M.','6m','month','week']
      tmark=[y_moy]

info0=' S2 = Origine + Pente*S1 '+' ==> S2 = '+STRCOMPRESS(STRING(r_coef[0],FORMAT='(F8.2)'),/REMOVE_ALL)+' + '+STRCOMPRESS(STRING(r_coef[1],FORMAT='(F8.2)'),/REMOVE_ALL)+'*S1'
info1='Origine = '+STRCOMPRESS(STRING(r_coef[0],FORMAT='(F8.2)'),/REMOVE_ALL)+' +/-'+STRCOMPRESS(STRING(err[0],FORMAT='(F8.2)'),/REMOVE_ALL)
info2='Pente   = '+STRCOMPRESS(STRING(r_coef[1],FORMAT='(F8.2)'),/REMOVE_ALL)+' +/-'+STRCOMPRESS(STRING(err[1],FORMAT='(F8.2)'),/REMOVE_ALL)
info3=STRING('Periode : ' ,print_date(s_start,/single),' --> ',print_date(s_end,/single))

info    = [info0,info1,info2,info3]
titre_x = 'Serie de reference (S1): '+name1+' N.M. = '+STRCOMPRESS(STRING(yref_moy,FORMAT='(F8.2)'),/REMOVE_ALL)
titre_y = 'Serie concordante  (S2): '+name2+' N.M. = '+STRCOMPRESS(STRING(y_moy,FORMAT='(F8.2)'),/REMOVE_ALL)
plot,yref,y,$
      xrange=xrange,yrange=yrange,psym=1,$
      XTITLE    = titre_x,$
      TITLE     = titre_y,$      
      POSITION  =[0.1,0.4,0.9,0.9]
xinfo    = REPLICATE(0.1,N_ELEMENTS(info))
yinfo    = 0.3-FINDGEN(N_ELEMENTS(info))*0.05
XYOUTS,xinfo,yinfo,info,CHARSIZE=1.,/NORMAL



;oplot,yref,yfit,COLOR=cgcolor('grey',254),psym=1
oplot,[0,MAX(yref)],[r_coef[0],r_coef[0]+MAX(yref)*r_coef[1]],COLOR=cgcolor('red',253)

IF KEYWORD_SET(cutinfo) THEN BEGIN
   col  = ['magenta','cyan','yellow','green','red','blue','navy','pink','aqua','orchid','sky','beige','charcoal','gray']
   para = read_cutinfo(cutinfo)
   Nd   = N_ELEMENTS(para.jmin)

   FOR i=0,Nd-1 DO BEGIN
      stx1 = julcut(st1$2,dmin=para[i].jmin,dmax=para[i].jmax)
      stx2 = julcut(st2$1,dmin=para[i].jmin,dmax=para[i].jmax)
      yref = stx1.val
      y    = stx2.val
      IF (N_ELEMENTS(yref) GT 2) THEN BEGIN
         ; calcul du doefficient de regression
         r_coef = LINFIT(y,yref,sigma=err,yfit=yfit)
         ;     y = r_coef[0]+r_coef[1]*yref
         IF KEYWORD_SET(verbose) THEN BEGIN
            PRINT,i," du ",print_date(para[i].jmin,/SINGLE),'---->',print_date(para[i].jmax,/SINGLE), 'col=',col[i]
            PRINT,"Serie-2 = a + b*Serie-1:"
            PRINT,FORMAT='(A28,X,F6.1,x,A3,X,F8.5)',      "regress. (b) entre S2/S1 est",r_coef[1],'+/-',err[1]
            PRINT,FORMAT='(A28,X,F6.1,x,A3,X,F8.2,x,A26)',"La serie (S2) est decalee de",r_coef[0],'+/-',err[0],"la serie de reference (S1)"
            PRINT,'---------------------------------------------------------------'
         ENDIF
         OPLOT,yref,yfit,color=cgcolor(col[i],254-i),PSYM=2,thick=1.
      ENDIF
   ENDFOR
ENDIF
IF (KEYWORD_SET(verbose) AND NOT KEYWORD_SET(cutinfo)) THEN BEGIN
            PRINT,"Serie-2 = a + b*Serie-1:"
            PRINT,FORMAT='(A28,X,F6.1,x,A3,X,F8.5)',      "regress. (b) entre S2/S1 est",r_coef[1],'+/-',err[1]
            PRINT,FORMAT='(A28,X,F6.1,x,A3,X,F8.2,x,A26)',"La serie (S2) est decalee de",r_coef[0],'+/-',err[0],"la serie de reference (S1)"
ENDIF
END
