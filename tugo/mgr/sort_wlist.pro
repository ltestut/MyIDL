FUNCTION sort_wlist, wlist, mgr, amp=amp, wave=wave, pha=pha
; fonction qui retourne la liste d'onde ranger dans l'ordre :
; /AMP  => des amplitudes decroissante
; /WAVE => des noms d'ondes croissant
; /PHA  => des phases croissantes

;on recupere les index de la wlist
;id par defaut classe les indices dans l'ordre croissant des noms d'ondes
ifinite = WHERE(FINITE(mgr.amp) AND mgr.amp GT 0.0)        ;on selectionne deja les ondes d'amplitude non nulles 
id      = cmset_op(mgr.wave[ifinite],'AND',wlist,/INDEX)   ;on selectionne deja les ondes d'amplitude non nulles
IF (N_PARAMS() EQ 2) THEN amp=1 ;par defaut on tri par amplitude
IF KEYWORD_SET(AMP) THEN jsort  = REVERSE(SORT(mgr.amp[ifinite[id]]))
IF KEYWORD_SET(PHA) THEN jsort  = REVERSE(SORT(mgr.pha[ifinite[id]]))
IF KEYWORD_SET(WAVE) THEN jsort = REVERSE(SORT(mgr.wave[ifinite[id]]))
new_wlist = mgr.wave[ifinite[id[jsort]]]
RETURN,new_wlist
END