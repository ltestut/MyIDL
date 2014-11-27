PRO write_mgr, mgr, filename=filename, scale=scale
; procedure d'ecriture d'une structure de type mgr dans un fichier ascii
; le fichier est ecrit dans l'ordre des amplitudes decroissantes

IF NOT KEYWORD_SET(scale) THEN scale=1.

nsta = N_ELEMENTS(mgr)
IF (KEYWORD_SET(filename)) THEN BEGIN
 out=filename                         ;on ajoute l'extension
 OPENW,  UNIT, out  , /GET_LUN        ;ouverture en ecriture du fichier
 FOR i=0,nsta-1 DO BEGIN
 IF (mgr[i].enr EQ "") THEN enr='Debut: 00/00/0000  Fin: 00/00/0000  Duree:   000' ELSE enr=mgr[i].enr  
 ;ecriture de l'entete de la station
 PRINTF,UNIT,'________________________________________________________________________________'
 PRINTF,UNIT,' '
 PRINTF,UNIT,' STATION No 0000  : ',mgr[i].name
 PRINTF,UNIT,' ORIGINE          : ',mgr[i].origine
 PRINTF,UNIT,' LOCALISATION     : ',STRING(mgr[i].lat,FORMAT='(F9.3)')+'N',STRING(mgr[i].lon,FORMAT='(F9.3)')+'E','    0.00m Triangle :     0
 PRINTF,UNIT,' ENREGISTREMENT   : ',enr     
 PRINTF,UNIT,' VALIDATION       : ',mgr[i].val
 wlist=sort_wlist(mgr[i].wave,mgr[i]) ;on tri dans l'ordre decroissant toutes les ondes /!\ avec cmset_op_uniq with sorting tides waves 2MS6 etc ..
 FOR j=0,N_ELEMENTS(wlist)-1 DO BEGIN ;on boucle sur toutes les ondes de la structure
   ik  = WHERE(mgr[i].wave EQ wlist[j], count1)   
   amp = mgr[i].amp[ik]*scale 
   pha = mgr[i].pha[ik]
   IF NOT FINITE(mgr[i].amp[ik]) THEN amp=0. ;pour ne pas avoir de NaN dans le fichier (xscan ne peut pas les lire)
   IF NOT FINITE(mgr[i].amp[ik]) THEN pha=0.
   PRINTF,UNIT,STRING(mgr[i].code[ik],FORMAT='(I3)'),'  ',STRING(mgr[i].wave[ik],FORMAT='(A-14)'),STRCOMPRESS(STRING(amp,FORMAT='(F10.6)')),'   ',STRCOMPRESS(STRING(pha,FORMAT='(F10.6)'))
  ENDFOR
 ENDFOR
FREE_LUN, UNIT
PRINT,'Ecriture de : ',filename
ENDIF ELSE BEGIN
 PRINT,'Need filename'
ENDELSE
END