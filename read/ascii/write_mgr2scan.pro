PRO write_mgr2scan,mgr,filename=filename

filename_info = getfilename(filename)
N             = N_ELEMENTS(mgr.lon)
;out           = filename_info.namestem+'.scan' ;on ajoute le sufixe .scan
out           = filename
cpt_pt        = 0L                              ;initialisation du compteur pour les multisegments xscan (lat=0,lon=0)
cpt_seg       = 0L

print, 'ecriture du fichier  ',out 

IF NOT KEYWORD_SET(seg_num) THEN seg_num=1

IF (KEYWORD_SET(filename)) THEN BEGIN
 OPENW,  UNIT, out  , /GET_LUN        ;; ouverture en ecriture du fichier
 PRINTF, UNIT, FORMAT='(I13,I13)', seg_num, N
 FOR I=0L,N-1 DO BEGIN
     cpt_pt=cpt_pt+1
     PRINTF, UNIT,FORMAT='(I12,X,F11.5,5X,F11.5)',cpt_pt,mgr[I].lon,mgr[I].lat
 ENDFOR
 FREE_LUN, UNIT
ENDIF
END