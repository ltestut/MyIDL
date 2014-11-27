PRO write_tab2xyz,  tab, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'write_tab2xyz,  tab, filename=nom du fichier'
 print, ''
 print, "INPUT : tab     : tableau "
 print, 'OUTPUT: filename: fichier ASCII'
 RETURN
ENDIF



IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENW,  UNIT, fic  , /GET_LUN        ;; ouverture en ecriture du fichier
;    FOR I=0L,Nd-1 DO BEGIN
       PRINTF, UNIT,FORMAT='(F12.4,",",F12.4,",",F12.4,",",F12.4,",",F12.4,",",F12.4,",",F12.4,",$")', tab
;    ENDFOR
 FREE_LUN, UNIT
 ENDIF

;; Derniere modif: 23/05/05
END
