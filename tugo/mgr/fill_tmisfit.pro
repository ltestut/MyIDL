FUNCTION fill_tmisfit,tmis, mgr1,mgr2, wlist=wlist, ista=ista, scale=scale, verbose=verbose
; programme qui compare deux structures de type .mgr
; ce prog compare sur le critere du nom de station (comparaison des noms de stations identiques)
; il fait ensuite pour chaque station la difference des validats (ensemble des constituents associes a une station *et* une origine) 
; une station peut avoir plusieurs validats c'est a dire plusieurs origines (annee differentes, methode d'analyse, observation ou modele, etc ...)

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

tmis.sta[ista].code  = ista 
tmis.sta[ista].name  = mgr1.name
tmis.sta[ista].org1  = mgr1.origine
tmis.sta[ista].org2  = mgr2.origine  
tmis.sta[ista].lon   = mgr1.lon
tmis.sta[ista].lat   = mgr1.lat 

FOR i=0,nb_wave-1 DO BEGIN    ;on parcours toute les ondes de la liste
 id1=WHERE(mgr1.wave EQ wlist[i], count1)
 id2=WHERE(mgr2.wave EQ wlist[i], count2)
  IF (count1 EQ 1 && count2 EQ 1) THEN BEGIN
   tmis.sta[ista].wave[i].name = mgr1.wave[id1]
   tmis.sta[ista].wave[i].da   = (mgr1.amp[id1]-mgr2.amp[id2])*scale
   tmis.sta[ista].wave[i].dp   = (mgr1.pha[id1]-mgr2.pha[id2])
   z1  = mgr1.amp[id1]*scale*EXP(jc*RAD(mgr1.pha[id1]))
   z2  = mgr2.amp[id2]*scale*EXP(jc*RAD(mgr2.pha[id2]))
   de  = ABS(z2-z1)
   tmis.sta[ista].wave[i].de   = de
   de_tab[cnt_wave]            = de
   cnt_wave                     = cnt_wave+1
  ENDIF ELSE BEGIN
   de_tab[cnt_wave]= !VALUES.F_NAN
   cnt_wave        = cnt_wave+1
  ENDELSE
ENDFOR
   tmis.sta[ista].rms          = SQRT(TOTAL(de_tab*de_tab,/NAN)/2)
IF KEYWORD_SET(verbose) THEN BEGIN
   PRINT,FORMAT='(A20,A20)',mgr1.name,mgr1.origine
   PRINT,FORMAT='(A25,'+STRCOMPRESS(nb_wave,/REMOVE_ALL)+'A13)','ONDES',wlist
   PRINT,FORMAT="(A10,'/',A14,"+STRCOMPRESS(nb_wave,/REMOVE_ALL)+"F13.3)",mgr2.name,mgr2.origine,de_tab
ENDIF
RETURN,tmis
END