PRO write_julval2list,  st, filename=filename, nogap=nogap, header=header, lon=lon,lat=lat, scale=scale

IF NOT KEYWORD_SET(nogap) THEN st = finite_st(st)
Nd = N_ELEMENTS(st.jul)

IF NOT KEYWORD_SET(lon)   THEN lon=0.0
IF NOT KEYWORD_SET(lat)   THEN lat=0.0
IF NOT KEYWORD_SET(scale) THEN scale=1.


IF (KEYWORD_SET(filename)) THEN BEGIN
    file=filename+'.list'
    OPENW,  UNIT, file  , /GET_LUN  ;; ouverture en ecriture du fichier
 IF KEYWORD_SET(header) THEN BEGIN
   PRINTF, UNIT,'# '+header
 ENDIF
    PRINTF, UNIT,'# 1er colonne jour julien CNES / au 01/01/1950 00:00:00'
    PRINTF, UNIT,'#Lon : '+STRCOMPRESS(STRING(lon,FORMAT='(F11.5)'),/REMOVE_ALL)
    PRINTF, UNIT,'#Lat : '+STRCOMPRESS(STRING(lat,FORMAT='(F11.5)'),/REMOVE_ALL)
    PRINTF, UNIT,'#Mes : '+STRCOMPRESS(STRING(Nd,FORMAT='(I11)'),/REMOVE_ALL)
    FOR I=0L,Nd-1 DO BEGIN
        PRINTF, UNIT,FORMAT='(F18.8,F11.4)', st[I].jul-JULDAY(1,1,1950,0,0,0),st[I].val*scale ;c Ecriture de la struture 
    ENDFOR
    FREE_LUN, UNIT
ENDIF


print,'Ecriture du fichier'
cd,cur=here
print,file

;; Derniere modif: 23/10/06
END
