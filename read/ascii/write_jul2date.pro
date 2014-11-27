PRO write_jul2date,  struct, filename=filename, suffix=suffix, header=header, rms=rms

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'write_jul2date,  struct, filename=nom du fichier'
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
out = filename ;fichier de sortie
 
IF KEYWORD_SET(suffix) THEN out=out+'.'+suffix

IF (KEYWORD_SET(filename)) THEN BEGIN
 OPENW,  UNIT, out  , /GET_LUN        ;; ouverture en ecriture du fichier
 IF KEYWORD_SET(header) THEN BEGIN
   PRINTF, UNIT,header
 ENDIF
 IF KEYWORD_SET(rms) THEN BEGIN
    FOR I=0L,Nd-1 DO BEGIN
       PRINTF, UNIT,FORMAT='(C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2),X,F9.3,X,F9.3)', struct[ITW[I]].jul,struct[ITW[I]].val,struct[ITW[I]].rms                   
    ENDFOR
 ENDIF ELSE BEGIN
    FOR I=0L,Nd-1 DO BEGIN
       PRINTF, UNIT,FORMAT='(C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2),X,F9.3)', struct[ITW[I]].jul,struct[ITW[I]].val     
    ENDFOR
 ENDELSE
 FREE_LUN, UNIT
 ENDIF

print,'  => ecriture du fichier au format jma :'
print,filename

;; Derniere modif: 21/05/05
END
