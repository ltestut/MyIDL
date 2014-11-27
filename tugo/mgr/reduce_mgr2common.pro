PRO reduce_mgr2common, mgr1_in, mgr2_in, mgr1, mgr2, nsta, nwav, common_wave, ncomb, verbose=verbose
; reduce mgr1_in and mgr2_in to their common *station name* and common *waves*
;   nsta        : number of common station
;   nwav        : number of common waves
;   common_wave : common wave list
;   ncomb       : number of possible combination for comparison   
; 
common_name  = cmset_op(mgr1_in.name,'AND',mgr2_in.name,COUNT=nsta)               ;nsta=Nbre of common station
common_wave  = cmset_op(REFORM(mgr1_in.wave,N_ELEMENTS(mgr1_in.wave)),'AND',$
                        REFORM(mgr2_in.wave,N_ELEMENTS(mgr2_in.wave)),COUNT=nwav) ;nwa =Nbre of common wave
ncomb = 0
IF (nsta GE 1) THEN BEGIN
 id1 = 0                                       ;init the station name index where mgr1 station match a common station
 id2 = 0                                       ;init the station name index where mgr2 station match a common station
 FOR i=0,nsta-1 DO BEGIN                       ;loop on each common *station name*
  idb1 = WHERE(mgr1_in.name EQ common_name[i],n1) ;index where mgr1_in match common *station name i* 
  idb2 = WHERE(mgr2_in.name EQ common_name[i],n2) ;index where mgr2_in match common *station name i*
  IF KEYWORD_SET(verbose) THEN PRINT,FORMAT='(%"##############station N°%02d [%s]###################")',i,common_name[i]
  IF KEYWORD_SET(verbose) THEN PRINT,FORMAT='(%"  *** Number of match in mgr1[%d] and mgr2[%d] *** ")',n1,n2
    IF (n1 GE 1 AND n2 GE 1) THEN BEGIN
      FOR j=0,n1-1 DO BEGIN                      ;loop on mgr1_in *origine* for *station name i*
             i_org2=WHERE(mgr2_in[idb2].origine EQ mgr1_in[idb1[j]].origine,n_org2,COMPLEMENT=id_org2d1,NCOMPLEMENT=nid_org2d1)
             ;index where mgr2_in match mgr1_in *station name* but not *origine*
             IF (nid_org2d1 GE 1) THEN BEGIN
             ncomb=ncomb+nid_org2d1
             IF KEYWORD_SET(verbose) THEN print,FORMAT='(%"  ===   mgr1[%d:%s]  N of diff ori in mgr2 = %d ==>  possible combination=%d")',$
                   j,mgr1_in[idb1[j]].origine,nid_org2d1,ncomb
             IF KEYWORD_SET(verbose) THEN print,"           mgr2.origine  ==>",mgr2_in[idb2[id_org2d1]].origine                   
             ENDIF
      ENDFOR
    ENDIF
  id1  = [id1,idb1]
  id2  = [id2,idb2]  
 ENDFOR 
  id1        = id1[1:N_ELEMENTS(id1)-1]
  id2        = id2[1:N_ELEMENTS(id2)-1]
  mgr1       = where_mgr(mgr1_in,id1)       ;reduce mgr1 to its index where it matches a common station
  mgr2       = where_mgr(mgr2_in,id2)       ;reduce mgr2 to its index where it matches a common station
  nval       = N_ELEMENTS(mgr1.name)        ;number of validats
 PRINT,'Origine fic. validation     :',mgr1[0].filename
 PRINT,'Nombre de station en commun :',nsta
 PRINT,'Nom des stations communes   :',common_name
 PRINT,'Nbre de validat a comparer  :',nval
 PRINT,'Nbre de comninaison possibl :',ncomb
  PRINT,"Nbre d'onde a  comparer     :",nwav
 PRINT,'Liste des ondes a comparer  :',common_wave
ENDIF ELSE BEGIN
  PRINT,"Aucune station en commun !"
ENDELSE
END