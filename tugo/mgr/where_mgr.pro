FUNCTION  where_mgr, mgr, id, wave=wave
; fonction qui selectionne dans une structure de type mgr :
; => soit des stations a partir de leur indice id
; => soit une onde particuliere a partir de son nom

IF (N_PARAMS() EQ 0) THEN STOP, 'st=WHERE_MGR(mgr,id)'

 ;parametres de la structure d'entree
ntag_mgr  = N_TAGS(mgr)
nsta      = N_ELEMENTS(mgr)

IF KEYWORD_SET(wave) THEN BEGIN
mgr1 = create_mgr(nsta,1)
idw  = INTARR(nsta)
FOR i=0,nsta-1 DO BEGIN 
 idw[i] = WHERE(mgr[i].wave EQ wave,cpt) 
 mgr1[i].name     = mgr[i].name
 mgr1[i].origine  = mgr[i].origine
 mgr1[i].enr      = mgr[i].enr
 mgr1[i].val      = mgr[i].val
 mgr1[i].lat      = mgr[i].lat
 mgr1[i].lon      = mgr[i].lon
 mgr1[i].filename = mgr[i].filename 
 mgr1[i].nwav     = 1
 IF (cpt EQ 1) THEN BEGIN
   mgr1[i].wave     = mgr[i].wave[idw[i]]         ;on remplit l'onde choisit
   mgr1[i].amp      = mgr[i].amp[idw[i]]
   mgr1[i].pha      = mgr[i].pha[idw[i]]
 ENDIF ELSE BEGIN
   mgr1[i].wave     = mgr[i].wave[idw[i]]         
   mgr1[i].amp      = !VALUES.F_NAN
   mgr1[i].pha      = !VALUES.F_NAN
 ENDELSE
 ENDFOR
ENDIF ELSE BEGIN
 IF (N_ELEMENTS(id) EQ 0)  THEN STOP, 'Need the index of the points id'
 ;determination du nombre maximum d'onde et creation de la structure .mgr
 nwav = N_ELEMENTS(mgr[0].amp)
 mgr1 = create_mgr(N_ELEMENTS(id),nwav)
 FOR i=0,ntag_mgr-1 DO mgr1.(i)=mgr[id].(i)
ENDELSE
RETURN, mgr1
END