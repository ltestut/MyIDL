FUNCTION mgr2de, mgr1,mgr2, wlist=wlist, scale=scale, verbose=verbose
; fonction qui calcul le module de la difference complex (dE) pour deux structures de type .mgr
; il n'y ici volontairement aucun test sur le nom ou l'origine des validats a comparer
; Les tests de comparaisons sur les validats doivent etre fait avant l'appel de la fonction
; de mgr2de

 ;gestion des mots-clefs, alertes et initialisation
IF ((N_ELEMENTS(mgr1) GT 1) OR (N_ELEMENTS(mgr2) GT 1)) THEN STOP,'/!\ mgr doit etre unidimensionnel'
IF NOT KEYWORD_SET(scale) THEN scale=1.
jc  = COMPLEX(0,1) ;i complexe
 ;on construite la liste des ondes communes dans l'ordre des amp de mgr1
auto_wlist   = cmset_op(mgr1.wave,'AND',mgr2.wave)
auto_wlist   = sort_wlist(auto_wlist,mgr1)
IF NOT KEYWORD_SET(wlist) THEN wlist=auto_wlist

nb_wave  = N_ELEMENTS(wlist)
cnt_wave = 0
de_tab   = FLTARR(nb_wave)
FOR i=0,nb_wave-1 DO BEGIN    ;on parcours toute les ondes de la liste
 id1=WHERE(mgr1.wave EQ wlist[i], count1)
 id2=WHERE(mgr2.wave EQ wlist[i], count2)
  IF (count1 EQ 1 && count2 EQ 1) THEN BEGIN
   z1  = mgr1.amp[id1]*scale*EXP(jc*RAD(mgr1.pha[id1]))
   z2  = mgr2.amp[id2]*scale*EXP(jc*RAD(mgr2.pha[id2]))
   de  = ABS(z2-z1)
   de_tab[cnt_wave]= de
   cnt_wave        = cnt_wave+1
  ENDIF ELSE BEGIN
   de_tab[cnt_wave]= !VALUES.F_NAN
   cnt_wave        = cnt_wave+1
  ENDELSE
ENDFOR
IF KEYWORD_SET(verbose) THEN BEGIN
   PRINT,FORMAT='(A50,A50)',mgr1.name,mgr1.origine
   PRINT,FORMAT='(A25,'+STRCOMPRESS(nb_wave,/REMOVE_ALL)+'A13)','ONDES',wlist
   PRINT,FORMAT="(A10,'/',A14,"+STRCOMPRESS(nb_wave,/REMOVE_ALL)+"F13.3)",mgr2.name,mgr2.origine,de_tab
ENDIF
RETURN,de_tab
END