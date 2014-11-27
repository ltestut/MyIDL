PRO write_julval,  struct, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'write_julval,  struct, filename=nom du fichier'
 print, ''
 print, "INPUT : struct :'nom_de_fichiers'"
 print, "INPUT : file   :'nom_de_fichiers'"
 print, 'OUTPUT: filename:fichier 2 colonnes de type jul val'
 RETURN
ENDIF


ITS = SORT(struct.jul)
struct.jul = struct[ITS].jul
struct.val = struct[ITS].val
ITW = WHERE(FINITE(struct.val) AND FINITE(struct.jul),Nd)
help,itw,its

IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENW,  UNIT, fic  , /GET_LUN        ;; ouverture en ecriture du fichier
 PRINTF, UNIT, Nd
    FOR I=0L,Nd-1 DO BEGIN
       PRINTF, UNIT,FORMAT='(F12.4,X,F9.3)', struct[ITW[I]].jul,struct[ITW[I]].val                  ;c Ecriture de la struture 
    ENDFOR
 FREE_LUN, UNIT
 ENDIF

;; Derniere modif: 05/05/03
END
