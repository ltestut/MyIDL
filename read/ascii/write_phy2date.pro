PRO write_phy2date,  struct, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'write_phy2date,  struct, filename=nom du fichier'
 print, ''
 print, "INPUT    : phy structure de type phy {jul,twat,bot,baro,mto} "
 print, "INPUT    : file  'nom_de_fichiers'"
 print, 'OUTPUT   : fichier 6  colonnes de type jul,twat,bot,baro,mto'
 RETURN
ENDIF


phy = tri_phy(struct)
Nd  = N_ELEMENTS(phy.jul)
IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENW,  UNIT, fic  , /GET_LUN        ;; ouverture en ecriture du fichier
; PRINTF, UNIT, Nd
    FOR I=0L,Nd-1 DO BEGIN
       PRINTF, UNIT,FORMAT='(C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2),X,F9.3,X,F9.3,X,F9.3,F9.3)', phy[I].jul,phy[I].twat,phy[I].bot,phy[I].baro,phy[I].mto
    ENDFOR
 FREE_LUN, UNIT
 ENDIF

;; Derniere modif: 21/05/05
END
