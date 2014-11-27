PRO write_monthly_table, st, stj, stm, stn, sta, samp, nval, nday, ndpm, Nmth, ny, ym, id_d, id_m, trend_a, $
                     moy_d, rms_d, trend_d, val_min_d, val_max_d, delta_d, $
                     moy_m, rms_m, trend_m, val_min_m, val_max_m, delta_m, $
                     tab_val, tab_nbr , ndpy, $
                     filename=filename, xls=xls, full=full, large=large, comment=comment

IF NOT KEYWORD_SET(comment)  THEN comment  = 'ajouter un commentaire'

OPENW,  UNIT, filename  , /GET_LUN
PRINT, 'Ecriture du fichier : ',filename
; on determine un format large ou court
IF KEYWORD_SET(xls) THEN BEGIN
cmt       = ' Donnees = '+comment
tab_mth   = ['year','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Mean']
fmt_lmthh = '(A4,X,13(A-6 ,X))' ;format ligne d'entete long
fmt_lyea  = '(I4,X,13(F6.1,X))' ;format ligne annuelles   
fmt_lmoy  = '(A4,X,13(F6.1,X))'
PRINTF,UNIT,cmt
PRINTF,UNIT,FORMAT=fmt_lmthh,tab_mth
FOR j=0,ny-1 DO BEGIN ;boucle sur le nombre d'annee (ou par ligne)
   PRINTF,UNIT,FORMAT=fmt_lyea,ym[0+j*12],tab_val[*,j],sta[j].val
ENDFOR
PRINTF   ,UNIT,FORMAT=fmt_lmoy,'Mean',moy_d[0:11],MEAN(sta.val,/NAN)
FREE_LUN, UNIT
CLOSE, UNIT
ENDIF ELSE BEGIN
IF KEYWORD_SET(large) THEN BEGIN
linedm  = '                                                                                             |      DAILY     |  MONTHLY  |'
lineh   = '---- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ |---| ----- ---- ----| ----- ----|'
line    = '---- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------       ----- ---- ----| ----- ----|'
line2   = '==== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======'
                fmt_lmthh = '(A4,X,12(A-6,X) ,A1,A3,A-2,A-5 ,X,A-4 ,X,A-4 ,A1,X,A-5 ,X,A-4 ,A1)' ;format ligne d'entete long
                fmt_lmth  = '(A4,X,12(A-6,X))'                                                   ;format ligne des mois long
                fmt_lyea  = '(I4,X,12(F6.1,X),A1,I3,A-2,F5.1,X,F4.1,X,F4.1,A1,X,F5.1,X,F4.1,A1)' ;format ligne annuelles   
                fmt_lnbj  = '(A4,X,12(I6,X))'                                                    ;format ligne du nombre de jour
                fmt_lndy  = '(A4,X,12(I6,X)  ,A5,  I5  ,A2,I4  ,A2, I4, A1)'
                fmt_lmoy  = '(A4,X,12(F6.1,X),A5,X,F5.1,A1,F5.1,A1,F5.1)'
                fmt_lrms  = '(A4,X,12(F6.1,X),A5,X,F5.1,A1,F5.1)'
                fmt_lmin  = '(A4,X,12(F6.1,X),A5,X,F6.1)'
ENDIF ELSE BEGIN ;                  
linedm  = '                                                                                 |      DAILY     |  MONTHLY  |'
lineh   = '---- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- |---| ----- ---- ----| ----- ----|'
line    = '---- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----       ----- ---- ----| ----- ----|'
line2   = '==== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ====='
                fmt_lmthh ='(A4,X,12(A-5,X), A1,A3,A-2,A-5 ,X,A-4 ,X,A-4 ,A1,X,A-5 ,X,A-4 ,A1)' ;format ligne d'entete court
                fmt_lmth  ='(A4,X,12(A-5,X))'                                                   ;format ligne des mois court
                fmt_lyea  = '(I4,X,12(F5.1,X),A1,I3,A-2,F5.1,X,F4.1,X,F4.1,A1,X,F5.1,X,F4.1,A1)' ;format ligne annuelles
                fmt_lnbj  = '(A4,X,12(I5,X))'                                                    ;format ligne du nombre de jour
                fmt_lndy  = '(A4,X,12(I5,X)  ,A5,X,I4  ,A2,I4  ,A2, I4, A1)'
                fmt_lmoy  = '(A4,X,12(F5.1,X),A5,X,F5.1,A1,F5.1,A1,F5.1)'
                fmt_lrms  = '(A4,X,12(F5.1,X),A5,X,F5.1,A1,F5.1)'
                fmt_lmin  = '(A4,X,12(F5.1,X),A5,X,F5.1)'
ENDELSE
; ecriture de l'entete du fichier  
space1  = '    |'
header1 = '                    -ooO TABLE DES MOYENNES MENSUELLES DES DONNEES JOURNALIERES Ooo-                   '
cmt     = ' Donnees = '+comment
header2 = '                             Echantillonnage initial de la serie      : '+STRCOMPRESS(STRING(samp,FORMAT='(F8.3)'),/REMOVE_ALL)+'H'
header3 = '                             Moy journaliere calculee pour au moins   : '+STRCOMPRESS(STRING(nval,FORMAT='(I4)')  ,/REMOVE_ALL)+' valeurs'
header4 = '                             Moy mensuelle calculee pour au moins     : '+STRCOMPRESS(STRING(nday,FORMAT='(I4)')  ,/REMOVE_ALL)+' jours'
header5 = '                             Moyenne de la serie journaliere complete : '+STRCOMPRESS(STRING(MEAN(stj.val,/NAN),FORMAT='(F8.2)')  ,/REMOVE_ALL)+' unit'
header6 = '                             Tendance des moyennes annuelles          : '+STRCOMPRESS(STRING(trend_a,FORMAT='(F8.2)')  ,/REMOVE_ALL)+' 10*unit/an'
tab_mth = ['year','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','|','day','|','Mean','Rms','Serr','|','Mean','Rms','|']
PRINTF,UNIT,header1
PRINTF,UNIT,cmt
PRINTF,UNIT,header2
PRINTF,UNIT,header3
PRINTF,UNIT,header4
PRINTF,UNIT,header5
PRINTF,UNIT,header6
PRINTF,UNIT,linedm
PRINTF,UNIT,lineh
PRINTF,UNIT,FORMAT=fmt_lmthh,tab_mth
PRINTF,UNIT,lineh

; boucle de calcul *ligne* des moyennes annuelles a partir des moyennes journalieres
; ===================================================================================
FOR j=0,ny-1 DO BEGIN ;boucle sur le nombre d'annee (ou par ligne)
   ;PRINTF,UNIT,FORMAT='(I4,X,12(F6.1,X),A1,I3,A2,F5.1,X,F4.1,X,F4.1,A2,F5.1,X,F4.1,A1)',ym[0+j*12],tab_val[*,j],'|',ndpy[j],'| ',sta[j].val,sta[j].rms,sta[j].rms/SQRT(ndpy[j]),'| ',MEAN(tab_val[*,j],/NAN),STDDEV(tab_val[*,j],/NAN),'|'
   PRINTF,UNIT,FORMAT=fmt_lyea,$
   ym[0+j*12],tab_val[*,j],'|',ndpy[j],'|',sta[j].val,sta[j].rms,sta[j].rms/SQRT(ndpy[j]),'|',MEAN(tab_val[*,j],/NAN),STDDEV(tab_val[*,j],/NAN),'|'
   IF KEYWORD_SET(full) THEN BEGIN
   PRINTF,UNIT,FORMAT=fmt_lnbj,'    ',tab_nbr[*,j]
   ENDIF                  
ENDFOR
PRINTF,UNIT,lineh

; le moyennes journalieres
PRINTF,UNIT,FORMAT=fmt_lndy,'Nday',Ndpm[0:11]     ,'Nd  =',Ndpm[12] ,'d/',N_ELEMENTS(id_d)      ,'m/',ny,'y'
PRINTF,UNIT,FORMAT=fmt_lmoy,'Mean',moy_d[0:11]    ,'Moy =',moy_d[12],'/' ,MEAN(moy_d[0:11],/NAN),'/',MEAN(sta.val,/NAN)
PRINTF,UNIT,FORMAT=fmt_lrms,'RMS ',rms_d[0:11]    ,'Rms =',rms_d[12],'/' ,STDDEV(moy_d[0:11],/NAN)
PRINTF,UNIT,FORMAT=fmt_lmin,'Min ',val_min_d[0:11],'Min =',val_min_d[12]
PRINTF,UNIT,FORMAT=fmt_lmin,'Max ',val_max_d[0:11],'Max =',val_max_d[12]
PRINTF,UNIT,FORMAT=fmt_lmin,'Dmax',delta_d[0:11]  ,'Dmax=',delta_d[12]
PRINTF,UNIT,FORMAT=fmt_lmin,'Trd ',trend_d[0:11]  ,'Trd =',trend_d[12]
; le moyennes mensuelles
PRINTF,UNIT,lineh
PRINTF,UNIT,FORMAT=fmt_lndy,'Nmth',Nmth[0:11]     ,'Nm  =',Nmth[12],  'm/',N_ELEMENTS(id_m),'m/',ny,'y'
PRINTF,UNIT,FORMAT=fmt_lmoy,'Mean',moy_m[0:11]    ,'Moy =',moy_m[12], '/' ,MEAN(moy_m[0:11],/NAN),'/',MEAN(sta.val,/NAN)
PRINTF,UNIT,FORMAT=fmt_lrms,'RMS ',rms_m[0:11]    ,'Rms =',rms_m[12], '/' ,STDDEV(moy_m[0:11],/NAN)
PRINTF,UNIT,FORMAT=fmt_lmin,'Min ',val_min_m[0:11],'Min =',val_min_m[12]
PRINTF,UNIT,FORMAT=fmt_lmin,'Max ',val_max_m[0:11],'Max =',val_max_m[12]
PRINTF,UNIT,FORMAT=fmt_lmin,'Dmax',delta_m[0:11]  ,'Dmax=',delta_m[12]
PRINTF,UNIT,FORMAT=fmt_lmin,'Trd ',trend_m[0:11]  ,'Trd =',trend_m[12]
PRINTF,UNIT,line2
PRINTF,UNIT,FORMAT=fmt_lmth,tab_mth[0:12]
FREE_LUN, UNIT
CLOSE, UNIT
ENDELSE


END