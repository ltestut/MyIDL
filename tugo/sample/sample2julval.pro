FUNCTION sample2julval, spl, name=name, verbose=verbose
; fonction qui renvoie une structure de type julval a partir d'une structure sample
; en fonction du nom de la station

IF NOT KEYWORD_SET(name) THEN STOP,'Donnez le nom de la station a extraire'

id = WHERE(spl.name EQ name,count)
IF (count EQ 1) THEN BEGIN
 st =  create_julval(N_ELEMENTS(spl[id].jul))
 st.jul = spl[id].jul
 st.val = spl[id].h
ENDIF
IF KEYWORD_SET(verbose) THEN PRINT,'Extraction de :',spl[id].name
RETURN, st
END