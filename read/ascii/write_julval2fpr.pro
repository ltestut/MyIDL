PRO write_julval2fpr,  st, filename=filename

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, "write_julval2fpr,  st, filename=filename"
 print, "         Ecriture d'un fichier .fpr a partir d'une structure de type {jul,val}"	
 print, "         Les fichiers .fpr sont utilisee pour l'analyse harmonique"
 print, "INPUT  ==>   structure de type {julval} "
 print, 'OUTPUT ==>   fichier filename.fpr"
 RETURN
ENDIF

st = finite_st(st)
Nd = N_ELEMENTS(st.jul)

IF (KEYWORD_SET(filename)) THEN BEGIN
    file=filename+'.fpr'
    OPENW,  UNIT, file  , /GET_LUN  ;; ouverture en ecriture du fichier
    PRINTF, UNIT, Nd
    PRINTF, UNIT, Nd
    FOR I=0L,Nd-1 DO BEGIN
        PRINTF, UNIT,FORMAT='(F15.8,F15.5)', st[I].jul-JULDAY(1,1,1985,0,0,0),st[I].val
    ENDFOR
    FREE_LUN, UNIT
ENDIF


print,'Ecriture du fichier'
cd,cur=here
print,here+'/'+file

;; Derniere modif: 26/10/06
END
