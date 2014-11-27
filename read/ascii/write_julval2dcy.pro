PRO write_julval2dcy,  st, filename=filename

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, "write_julval2decyear,  st, filename=filename"
 print, "         Ecriture d'un fichier .dcy a partir d'une structure de type {jul,val}"
 print, "         Les fichiers .dcy sont exprime en annees decimal "
 print, "INPUT  ==>   structure de type {julval} "
 print, 'OUTPUT ==>   fichier filename.dcy"
 RETURN
ENDIF

st = finite_st(st)
Nd = N_ELEMENTS(st.jul)
CALDAT,st.jul,mth,day,yr

IF (KEYWORD_SET(filename)) THEN BEGIN
    file=filename+'.dcy'
    OPENW,  UNIT, file  , /GET_LUN  ;; ouverture en ecriture du fichier
    PRINTF, UNIT, Nd
    FOR I=0L,Nd-1 DO BEGIN
        PRINTF, UNIT,FORMAT='(F15.8,F15.5)', yr[I]+(st[I].jul-JULDAY(1,1,yr[I],0,0,0))/365.,st[I].val
    ENDFOR
    FREE_LUN, UNIT
ENDIF


print,'Ecriture du fichier'
cd,cur=here
print,here+'/'+file

;; Derniere modif: 23/11/06
END
