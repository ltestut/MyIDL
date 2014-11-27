PRO write_daily_table, st, stc, stj, tab_val, samp, nval, $
                     filename=filename, xls=xls, full=full, comment=comment

IF NOT KEYWORD_SET(comment)  THEN comment  = 'ajouter un commentaire'

moy_mens = MAKE_ARRAY(12,/FLOAT,VALUE=!VALUES.F_NAN) ;calcule de la moyenne des donnees journalieres
FOR i=0,11 DO moy_mens[i] = MEAN(tab_val[i,*],/NAN)
stm  = monthly_mean(stc)

OPENW,  UNIT, filename  , /GET_LUN
PRINT, 'Ecriture du fichier : ',filename
; on determine un format large ou court
   linedm  = '                                                                                         '
   lineh   = '---- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ '
   line    = '---- ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ ------ '
   line2   = '==== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======'
                fmt_lmth  = '(A4,X,12(A-6,X))' ;format ligne des mois long
                fmt_lyea  = '(I4,X,12(F6.1,X))' ;format ligne journaliere  
                fmt_lmoy  = '(A4,X,12(F6.1,X))' ;format ligne de moyenne
; ecriture de l'entete du fichier  
   space1  = '    |'
   header1 = '                    -ooO TABLE DES MOYENNES MENSUELLES DES DONNEES JOURNALIERES Ooo-                   '
   cmt     = ' Donnees = '+comment
   header2 = '                             Echantillonnage initial de la serie      : '+STRCOMPRESS(STRING(samp,FORMAT='(F8.3)'),/REMOVE_ALL)+'H'
   header3 = '                             Moy journaliere calculee pour au moins   : '+STRCOMPRESS(STRING(nval,FORMAT='(I4)')  ,/REMOVE_ALL)+' valeurs'
   header4 = '                             Moyenne de la serie journaliere complete : '+STRCOMPRESS(STRING(MEAN(stj.val,/NAN),FORMAT='(F8.2)')  ,/REMOVE_ALL)+' unit'
   tab_mth = ['day ','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
   PRINTF,UNIT,header1
   PRINTF,UNIT,cmt
   PRINTF,UNIT,header2
   PRINTF,UNIT,header3
   PRINTF,UNIT,header4
   PRINTF,UNIT,linedm
   PRINTF,UNIT,lineh
   PRINTF,UNIT,FORMAT=fmt_lmth,tab_mth
   PRINTF,UNIT,lineh

; boucle de calcul *ligne* des moyennes annuelles a partir des moyennes journalieres
; ===================================================================================
FOR j=0,30 DO BEGIN ;boucle sur le nombre d'annee (ou par ligne)
   PRINTF,UNIT,FORMAT=fmt_lyea,j+1,tab_val[*,j]
ENDFOR
PRINTF,UNIT,line2
PRINTF,UNIT,FORMAT=fmt_lmoy,'moy ',moy_mens
PRINTF,UNIT,FORMAT=fmt_lmoy,'moy ',stm[*].val
FREE_LUN, UNIT
CLOSE, UNIT
END