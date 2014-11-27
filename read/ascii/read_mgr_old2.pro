function read_mgr_old2, filename, nname=nname 
; fonction qui permet de lire les fichiers de sortie d'analyse harmonique au format .mgr
; nname='ddu' : permet de forcer le champ st.station_name dans la structure de sortie
;             : par defaut st.station_name = le nom de station inclus dans le fichier mgr (s'il y en a un !)

mgr_template = {version:1.0,$
       datastart:7   ,$
       delimiter: ''  ,$
       missingvalue: 0   ,$
       commentsymbol: ''  ,$
       fieldcount:4 ,$
       fieldTypes:[2,7,4,4], $
       fieldNames:['code','wave','amp','pha'] ,$
       fieldLocations:[1,5,20,31], $
       fieldGroups:indgen(4) $
      }

read_st  = READ_ASCII(filename,TEMPLATE=mgr_template)
; on lit et on range dans l'ordre decroissant 
dsc_ord      = REVERSE(SORT(read_st.amp))
read_st.code = read_st.code[dsc_ord]
read_st.wave = read_st.wave[dsc_ord]
read_st.pha  = read_st.pha[dsc_ord]
read_st.amp  = read_st.amp[dsc_ord]
; on creer un structure de type mgr et on range les donnees dedans 
mgr_st      = create_mgr(N_ELEMENTS(read_st.code))
mgr_st.code = read_st.code
mgr_st.wave = read_st.wave
mgr_st.amp  = read_st.amp
mgr_st.pha  = read_st.pha

count  = 0
id_neg = WHERE(mgr_st.pha LT 0., count)
IF (count GT 0) THEN mgr_st.pha[id_neg]=mgr_st.pha[id_neg]+360


; ouverture du fichier .mgr et initialisation des chaines de caracteres
; pour detecter le nom de la station et ces coordonnees geographiques et remplir
; les champs correspondants
OPENR, mgr_LUN, filename, /GET_LUN
done=0
line=''
trash=''
trash1=''
trash2=''
lat=''
lon=''

WHILE (done NE 2 OR NOT EOF(mgr_LUN)) DO BEGIN
  READF, mgr_LUN,line
  IF (STREGEX(line, 'STATION', /BOOLEAN)) THEN BEGIN
    READS, line, FORMAT='(A20,A30)', trash, trash1
    mgr_st.station_name=trash1
    IF KEYWORD_SET(nname) THEN mgr_st.station_name=nname 
    done = done+1
  ENDIF 
  IF (STREGEX(line, 'LOCALISATION', /BOOLEAN)) THEN BEGIN
    READS, line, FORMAT='(A22,A7,A2,A8)', trash, lat, trash2, lon
    mgr_st.lat=lat
    mgr_st.lon=lon
    done=done+1
  ENDIF
ENDWHILE 
  RETURN, mgr_st
END